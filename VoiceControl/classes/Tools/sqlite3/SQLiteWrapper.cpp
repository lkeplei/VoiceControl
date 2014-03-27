/*
 SQLiteWrapper.cpp
 
 Copyright (C) 2004 René Nyffenegger
 
 This source code is provided 'as-is', without any express or implied
 warranty. In no event will the author be held liable for any damages
 arising from the use of this software.
 
 Permission is granted to anyone to use this software for any purpose,
 including commercial applications, and to alter it and redistribute it
 freely, subject to the following restrictions:
 
 1. The origin of this source code must not be misrepresented; you must not
 claim that you wrote the original source code. If you use this source code
 in a product, an acknowledgment in the product documentation would be
 appreciated but is not required.
 
 2. Altered source versions must be plainly marked as such, and must not be
 misrepresented as being the original source code.
 
 3. This notice may not be removed or altered from any source distribution.
 
 René Nyffenegger rene.nyffenegger@adp-gmbh.ch
 
 */

#include "SQLiteWrapper.h"
#include <iostream.h>

SQLiteWrapper::SQLiteWrapper():db_(NULL){
}

bool SQLiteWrapper::Open(std::string const& db_file){
	if(sqlite3_open(db_file.c_str(),&db_)!=SQLITE_OK){
		return false;
	}
	return true;
}

long long SQLiteWrapper::lastInsertRowid()
{
    return sqlite3_last_insert_rowid(db_);
}

bool SQLiteWrapper::SelectStmt(std::string const& stmt,ResultTable& res){
	char * errmsg = NULL;
	int ret = SQLITE_OK;
	
	res.reset();
	
	ret=sqlite3_exec(db_,stmt.c_str(),SelectCallback,static_cast<void*>(&res),&errmsg);
	
	if (ret!=SQLITE_OK){
		
		if (errmsg) {
			std::cout << stmt << " [" << errmsg << "]" << std::endl;
		}
		else {
			std::cout << stmt << " unknow ret=" << ret << std::endl;
		}
		
		return false;
	}
	
	return true;
}

// TODO parameter p_col_names
int SQLiteWrapper::SelectCallback(void *p_data,int num_fields,char **p_fields,char** p_col_names) {
	ResultTable* res=reinterpret_cast<ResultTable*>(p_data);
	
	ResultRecord record;
	
#ifdef SQLITE_WRAPPER_REPORT_COLUMN_NAMES
	// Hubert Castelain: column names in the first row of res if res is empty
	
	if(res->records_.size()==0) {
		ResultRecord col_names;
		
		for(int i=0;i<num_fields;i++){
			if(p_fields[i])
				col_names.fields_.push_back(p_col_names[i]);
			else
				col_names.fields_.push_back("(null)"); // or what else ?
		}
		res->records_.push_back(col_names);
	}
#endif
	
	for(int i=0;i<num_fields;i++) {
		// Hubert Castelain: special treatment if null
		if(p_fields[i])
			record.fields_.push_back(p_fields[i]);
		else
			record.fields_.push_back("<null>");
	}
	
	res->records_.push_back(record);
	
	return 0;
}

SQLiteStatement* SQLiteWrapper::Statement(std::string const& statement){
	SQLiteStatement* stmt;
	try{
		stmt=new SQLiteStatement(statement,db_);
		return stmt;
	}
	catch(const char* e){
		return NULL;
	}
}

SQLiteStatement::SQLiteStatement(std::string const& statement,sqlite3* db) {
	if(sqlite3_prepare(
					   db,
					   statement.c_str(), // stmt
					   -1, /*读取的字节长度，若小于0，则终止；若大于0，则为能读取的最大字节数*/
					   &stmt_, /*用来指向输入参数中下一个需要编译的SQL语句存放的SQLite statement对象的指针*/
					   0 /*指针：指向stmt未编译的部分*/
					   )
	   !=SQLITE_OK){
		throw sqlite3_errmsg(db);
	}
	
	if(!stmt_){
		throw "stmt_ is 0";
	}
}

SQLiteStatement::~SQLiteStatement(){
	
	// 语法: int sqlite3_finalize(sqlite3_stmt *pStmt);
	if(stmt_){
		sqlite3_finalize(stmt_);
		stmt_ = NULL ;
	}
}

SQLiteStatement::SQLiteStatement():stmt_(0)
{
}

bool SQLiteStatement::Bind(int pos_zero_indexed,std::string const& value){
	if (sqlite3_bind_text(
						  stmt_,
						  pos_zero_indexed+1, // 通配符索引
						  value.c_str(),
						  (int)value.length(), // 文本长度
						  SQLITE_TRANSIENT // SQLITE_TRANSIENT: SQLite 自我复制
						  )
		!=SQLITE_OK) {
		return false;
	}
	return true;
}

bool SQLiteStatement::Bind(int pos_zero_indexed, double value) {
	if(sqlite3_bind_double(
						   stmt_,
						   pos_zero_indexed+1, // 通配符索引
						   value
						   )
	   !=SQLITE_OK) {
		return false;
	}
	return true;
}

bool SQLiteStatement::Bind(int pos_zero_indexed,int value) {
	if (sqlite3_bind_int(
						 stmt_,
						 pos_zero_indexed+1, // 通配符索引
						 value
						 )
		!=SQLITE_OK){
		return false;
	}
	return true;
}

bool SQLiteStatement::BindNull(int pos_zero_indexed){
	if (sqlite3_bind_null(
						  stmt_,
						  pos_zero_indexed+1 // 通配符索引
						  )
		!=SQLITE_OK) {
		return false;
	}
	return true;
}

bool SQLiteStatement::Execute() {
	int rc=sqlite3_step(stmt_);
	if (rc==SQLITE_BUSY){
//        sqlite3_busy_timeout(db_, 1000);
		std::cout << "SQLiteStatement::SQLITE_BUSY"<< std::endl;
		return false;
	}
	if(rc==SQLITE_ERROR){
		std::cout << "SQLiteStatement::SQLITE_ERROR"<< std::endl;
		return false;
	}
	if(rc==SQLITE_MISUSE){
		std::cout << "SQLiteStatement::SQLITE_ERROR"<< std::endl;
		return false;
	}
	if(rc!=SQLITE_DONE){
		std::cout << "SQLiteStatement::Execute rc=" << rc << std::endl;
		return false;
	}
	sqlite3_reset(stmt_);
	return true;
}

SQLiteStatement::dataType SQLiteStatement::DataType(int pos_zero_indexed){
	return dataType(sqlite3_column_type(stmt_, pos_zero_indexed));
}

int SQLiteStatement::ValueInt(int pos_zero_indexed){
	return sqlite3_column_int(stmt_,pos_zero_indexed);
}

std::string SQLiteStatement::ValueString(int pos_zero_indexed){
	return std::string(reinterpret_cast<const char*>(sqlite3_column_text(stmt_,pos_zero_indexed)));
}

bool SQLiteStatement::RestartSelect(){
	sqlite3_reset(stmt_);
	return true;
}

bool SQLiteStatement::Reset(){
	int rc=sqlite3_step(stmt_);
	
	sqlite3_reset(stmt_);
	
	if (rc==SQLITE_ROW) 
		return true;
	
	return false;
}

bool SQLiteStatement::NextRow() {
	int rc=sqlite3_step(stmt_);
	
	if (rc==SQLITE_ROW){
		return true;
	}
	if(rc==SQLITE_DONE){
		sqlite3_reset(stmt_);
		return false;
	}
	else if(rc==SQLITE_MISUSE){
		std::cout << "SQLiteStatement::NextRow SQLITE_MISUSE"<< std::endl;
	}
	else if(rc==SQLITE_BUSY){
		std::cout << "SQLiteStatement::NextRow SQLITE_BUS"<< std::endl;
	}
	else if(rc==SQLITE_ERROR){
		std::cout << "SQLiteStatement::NextRow SQLITE_ERROR"<< std::endl;
	}
	return false;
}

bool SQLiteWrapper::DirectStatement(std::string const& stmt){
	char *errmsg = NULL;
	int ret;
	
	ret=sqlite3_exec(db_,stmt.c_str(),0,0,&errmsg);
	
	if(ret!=SQLITE_OK) {
		if (errmsg) {
			std::cout << stmt << " [" << errmsg << "]" << std::endl;
		}
		else {
			std::cout << stmt << " unknow ret=" << ret << std::endl;
		}
		return false;
	}
	return true;
}

std::string SQLiteWrapper::LastError(){
	return sqlite3_errmsg(db_);
}

bool SQLiteWrapper::Begin(){
	return DirectStatement("begin");
}

bool SQLiteWrapper::Commit(){
	return DirectStatement("commit");
}

bool SQLiteWrapper::Rollback(){
	return DirectStatement("rollback");
}