#!/usr/bin/python

import os,sys
import pysnmp
import netsnmp

def getmac():
        oid = netsnmp.VarList(netsnmp.Varbind('.1.3.6.1.2.1.17.7.1.2.2.1.2'))
        res = netsnmp.snmpgetbulk(oid, Version = 1, DestHost='192.168.110.101', Community='Velocity')
        return res

def try2():
        with netsnmp.Session('192.168.110.101', 'Velocity') as ss:
#               return ss.get(['.1.3.6.1.2.1.1.1.0', '.1.3.6.1.2.1.1.3.0', '.1.3.6.1.2.1.1.5.0'])
                return ss.get('.1.3.6.1.4.1.2.3.51.3.1.15.17.1.3.1')

def try3(oid):
#       ss = netsnmp.Session(DestHost='192.168.110.101',Version=1,Community='Velocity')
#       return ss.snmpget(oid)
#       return netsnmp.snmpwalk(oid,1,"192.168.110.101","Velocity")
        return netsnmp.snmpwalk(oid,DestHost='192.168.110.101',Version=1,Community='Velocity')



print "helloworld"
thisoid = '.1.3.6.1.4.1.2.3.51.3.1.15.17.1.3.1'
thisoid = '.1.3.6.1.4.1.2.3.51.3.1.13.1.4'
print "Ctrl"
print try3(thisoid)
print "Driveids"
thisoid = '.1.3.6.1.4.1.2.3.51.3.1.13.1.5.1.1'
driveids = netsnmp.snmpwalk(thisoid,DestHost='192.168.110.101',Version=1,Community='Velocity')
for x in driveids:
        print x
        desc = ".2"
        identifier = ".3"
        size = ".4"
        start = '.1.3.6.1.4.1.2.3.51.3.1.13.1.5.1'
        thisid = start + identifier+ "." + x
        thisid_desc = netsnmp.snmpget(thisid,DestHost='192.168.110.101',Version=1,Community='Velocity')
        print "id {0} is {1} ({2}) ".format(x,thisid_desc[0],thisid)


print "drives"
thisoid = '.1.3.6.1.4.1.2.3.51.3.1.13.1.5'
thisoid = '.1.3.6.1.4.1.2.3.51.3.1.13.1.5'
print try3(thisoid)

