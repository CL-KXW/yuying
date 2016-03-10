//
//  SqlHeader.h
//  KOShow
//
//  Created by 陈磊 on 16/1/19.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#ifndef SqlHeader_h
#define SqlHeader_h

//@"INSERT INTO USER (name,age,idcode) VALUES (?,?,?) "
//#define UPDATA_DATA         @"UPDATE USER  SET name = ? , age = ? where idcode = ?";

#define HISTORY_TABLE_NAME          @"SearchHistory"
#define HISTORY_TABLE_FILE          @"SearchHistory.sqlite"

#define INSTER_DATA_SQL             @"INSERT INTO SearchHistory (keyWord) VALUES (?)"

#define QUERY_TABLE_SQL             @"SELECT * FROM SearchHistory"

#define DELETE_ALL_DATA             @"Delete from SearchHistory where 1=1"



#endif /* SqlHeader_h */
