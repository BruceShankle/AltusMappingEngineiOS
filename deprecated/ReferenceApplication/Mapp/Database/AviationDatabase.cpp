//
//  AviationDatabase.cpp
//  Mapp
//
//  Created by Edwin B Shankle III on 8/2/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//
#include <iostream>
#include <sstream>
#include "AviationDatabase.h"

using namespace std;
using namespace AviationData;

AviationDatabase::AviationDatabase(std::string filename)
:SQLiteDB(filename)
{
	//Precompile sql statements
    string sql;
    sql = "SELECT * FROM airport WHERE longitude>=?1 AND latitude>=?2 AND longitude<=?3 and latitude<=?4";
	CompileQuery(sql, &_airportsWithinBoundsStmt);
    
    sql = "SELECT * FROM airport WHERE id=?1";
    CompileQuery(sql, &_airportWithIDStmt);
    
    sql = "SELECT * FROM runway WHERE site_number=?1";
    CompileQuery(sql, &_runwaysWithSiteNumberStmt);
    
    sql = "SELECT * FROM airport";
    CompileQuery(sql, &_allAirportsStmt);
    
}

AviationDatabase::~AviationDatabase()
{
	//Free compiled queries
	sqlite3_finalize(_airportsWithinBoundsStmt);
    sqlite3_finalize(_airportWithIDStmt);
    sqlite3_finalize(_runwaysWithSiteNumberStmt);
    sqlite3_finalize(_allAirportsStmt);
}

//Copies data from query into runway struct
Runway AviationDatabase::runwayFromStmt(sqlite3_stmt *pdbstmt)
{
    Runway runway;
    int column=0;
    runway.uid = sqlite3_column_int(pdbstmt, column++);
    runway.site_number = reinterpret_cast<const char*>(sqlite3_column_text(pdbstmt, column++));
    runway.runway_id = reinterpret_cast<const char*>(sqlite3_column_text(pdbstmt, column++));
    runway.length = sqlite3_column_int(pdbstmt, column++);
    runway.start.longitude = sqlite3_column_double(pdbstmt, column++);
    runway.start.latitude = sqlite3_column_double(pdbstmt, column++);
    runway.end.longitude = sqlite3_column_double(pdbstmt, column++);
    runway.end.latitude = sqlite3_column_double(pdbstmt, column++);
    return runway;
}

//Returns a list of runways
vector<Runway> AviationDatabase::runwaysWithSiteNumber(std::string site_number)
{
    vector<Runway> runways;
    
    //Bind input parammeters
    sqlite3_bind_text(_runwaysWithSiteNumberStmt, 1, site_number.c_str(), -1, SQLITE_STATIC );
    
	//Iterate over results
	while(true)
	{
		int result=sqlite3_step(_runwaysWithSiteNumberStmt);
		if(result==SQLITE_ROW)
		{
            runways.push_back(runwayFromStmt(_runwaysWithSiteNumberStmt));
		}
		else
			break;
	}
    
    ResetAndClear(_runwaysWithSiteNumberStmt);
    
    //Return data
    return runways;
}

//Copies data from query into airport struct
Airport AviationDatabase::airportFromStmt(sqlite3_stmt *pdbstmt)
{
    Airport airport;
    
    //Get the data from the statement.
    int column=0;
    airport.uid = sqlite3_column_int(pdbstmt, column++);
    airport.site_number = reinterpret_cast<const char*>(sqlite3_column_text(pdbstmt, column++));
    airport.facility_id = reinterpret_cast<const char*>(sqlite3_column_text(pdbstmt, column++));
    airport.city = reinterpret_cast<const char*>(sqlite3_column_text(pdbstmt, column++));
    airport.state = reinterpret_cast<const char*>(sqlite3_column_text(pdbstmt, column++));
    airport.phone = reinterpret_cast<const char*>(sqlite3_column_text(pdbstmt, column++));
    airport.location.longitude = sqlite3_column_double(pdbstmt, column++);
    airport.location.latitude = sqlite3_column_double(pdbstmt, column++);
    
    //Get all the runways
    airport.runways = runwaysWithSiteNumber(airport.site_number);
    
    //Get max runway length
    airport.maxRunwayLength=0;
    for(int i=0; i<airport.runways.size(); i++)
    {
        airport.maxRunwayLength = max(airport.maxRunwayLength, airport.runways[i].length);
    }
    
    //Return the airport
    return airport;
}

//Load a single airport from the database with the given id
Airport AviationDatabase::airportWithID(int uid)
{
    sqlite3_bind_int(_airportWithIDStmt, 1, uid);
    int result=sqlite3_step(_airportWithIDStmt);
    Airport airport;
    if(result==SQLITE_ROW)
    {
        airport = airportFromStmt(_airportWithIDStmt);
    }
    ResetAndClear(_airportWithIDStmt);
    return airport;
}

std::vector<Airport> AviationDatabase::allAirports()
{
    vector<Airport> airports;
        
    //Iterate over results
	while(true)
	{
		int result=sqlite3_step(_allAirportsStmt);
		if(result==SQLITE_ROW)
		{
			airports.push_back(airportFromStmt(_allAirportsStmt));
		}
		else
			break;
	}
    
    ResetAndClear(_allAirportsStmt);
    
    //Return data
	return airports;
}

//Returns a vector of airports within a geographic bounds
vector<Airport> AviationDatabase::airportsWithinBounds(float minX, float minY, float maxX, float maxY)
{
	vector<Airport> airports;
    
    //Bind input parammeters
    int parm=1;
	sqlite3_bind_double(_airportsWithinBoundsStmt, parm++, minX);
	sqlite3_bind_double(_airportsWithinBoundsStmt, parm++, minY);
	sqlite3_bind_double(_airportsWithinBoundsStmt, parm++, maxX);
	sqlite3_bind_double(_airportsWithinBoundsStmt, parm++, maxY);
    
    //Iterate over results
	while(true)
	{
		int result=sqlite3_step(_airportsWithinBoundsStmt);
		if(result==SQLITE_ROW)
		{
			airports.push_back(airportFromStmt(_airportsWithinBoundsStmt));
		}
		else
			break;
	}
    
    ResetAndClear(_airportsWithinBoundsStmt);
    
    //Return data
	return airports;
}
