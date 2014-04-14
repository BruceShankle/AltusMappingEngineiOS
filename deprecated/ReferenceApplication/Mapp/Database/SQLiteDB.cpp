//
//  SQLiteDatabase.cpp
//  ME
//
//  Created by Edwin B Shankle III on 8/2/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#include "SQLiteDB.h"
#include <iostream>
#include <assert.h>

using namespace std;

SQLiteDB::SQLiteDB(std::string filename)
: _filename(filename)
{
	if (sqlite3_open_v2(_filename.c_str(), &_pdb, SQLITE_OPEN_SHAREDCACHE | SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
	{
        //cout << _filename << " opened." << endl;
        return;
	}
	else
	{
		//Could not open database file
		cout << "Database " << filename << " could not be opened." << endl;
		assert(false);
	}
}

SQLiteDB::~SQLiteDB()
{
	sqlite3_close(_pdb);
	_pdb=NULL;
}

void SQLiteDB::ResetAndClear(sqlite3_stmt* queryStmt)
{
    sqlite3_clear_bindings(queryStmt);
	sqlite3_reset(queryStmt);
}

void SQLiteDB::CompileQuery(std::string sql, sqlite3_stmt** queryStmt)
{
	if(sqlite3_prepare_v2(_pdb, sql.c_str(), -1, queryStmt, NULL)!=SQLITE_OK)
	{
		cout << "Error compiling " << sql << endl;
		assert(false);
	}
}
