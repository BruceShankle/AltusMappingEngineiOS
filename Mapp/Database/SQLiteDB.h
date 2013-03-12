//
//  SQLiteDatabase.h
//  ME
//
//  Created by Edwin B Shankle III on 8/2/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//
#pragma once
#include <string>
#include <sqlite3.h>

class SQLiteDB
{
public:
    SQLiteDB(std::string filename);
	virtual ~SQLiteDB();
	void CompileQuery(std::string sql, sqlite3_stmt** queryStmt);
    void ResetAndClear(sqlite3_stmt* queryStmt);
    
protected:
	std::string _filename;
	sqlite3* _pdb;
};