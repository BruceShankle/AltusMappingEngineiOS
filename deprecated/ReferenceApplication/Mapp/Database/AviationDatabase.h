//
//  AviationDatabase.h
//  Mapp
//
//  Created by Edwin B Shankle III on 8/2/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//
#pragma once

#include "SQLiteDB.h"
#include <vector>

namespace AviationData
{
	struct Point
	{
		Point(){}
		Point(float longitude, float latitude)
		:longitude(longitude), latitude(latitude){}
		Point(float longitude, float latitude, float alitude)
		:longitude(longitude), latitude(latitude), altitude(altitude){}
		float longitude;
		float latitude;
		float altitude;
	};
	
	struct Airspace
	{
		std::vector<Point> points;
	};
	
    struct Runway
    {
        Runway()
        :uid(0), site_number(""), runway_id(""), start(Point(0,0)), end(Point(0,0)),length(0){}
        int uid;
        std::string site_number;
        std::string runway_id;
        Point start;
        Point end;
        int length;
    };
    
	struct Airport
	{
        Airport():uid(0),
        facility_id(""),
        city(""),
        state(""),
        phone(""),
        location(Point(0,0)),
        runways(std::vector<Runway>()),
        maxRunwayLength(0)
        {}
        int uid;
        std::string facility_id;
        std::string site_number;
        std::string city;
        std::string state;
        std::string phone;
        Point location;
        std::vector<Runway>runways;
        int maxRunwayLength;
    };
	
	class AviationDatabase : public SQLiteDB
	{
	public:
		AviationDatabase(std::string filename);
		~AviationDatabase();
		
        std::vector<Airport> allAirports();
        std::vector<Airport> airportsWithinBounds(float minX, float minY, float maxX, float maxY);
        std::vector<Runway> runwaysWithSiteNumber(std::string site_number);
        Airport airportWithID(int uid);
	protected:
        Airport airportFromStmt(sqlite3_stmt* pdbstmt);
        Runway runwayFromStmt(sqlite3_stmt* pdbstmt);
        sqlite3_stmt* _allAirportsStmt;
		sqlite3_stmt* _airportsWithinBoundsStmt;
        sqlite3_stmt* _airportWithIDStmt;
        sqlite3_stmt* _runwaysWithSiteNumberStmt;
	};
}
