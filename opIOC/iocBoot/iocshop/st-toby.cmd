#!../../bin/linux-x86_64/shop

## You may have to change temp to something else
## everywhere it appears in this file

< envPaths

cd ${TOP}

epicsThreadSleep(5)

## Register all support components
dbLoadDatabase("dbd/shop.dbd")
shop_registerRecordDeviceDriver(pdbbase)




# set this for Stream Device protocol file locations
epicsEnvSet ("STREAM_PROTOCOL_PATH", ".:../protocols")






drvAsynSerialPortConfigure("shopComm", "/dev/ttyUSB0")
asynSetOption("shopComm", 0, "baud", "2400")
asynSetOption("shopComm", 0, "bits", "8")
asynSetOption("shopComm", 0, "parity", "none")
asynSetOption("shopComm", 0, "stop", "1")





drvAsynIPPortConfigure ("ConsoleMoxa", "192.168.0.48:4001",0,0)






#Records for communicating with Canberra Radiation Monitors

dbLoadRecords("db/Rad/RadiationMonitor.vdb","SubSys=Shop, Group=Rad, Device=Vault, ReadMSG=read8892Vault, DeviceName=shopComm, ProtoFile=adm606M.proto")

dbLoadRecords("db/Rad/RadiationMonitorLogic.vdb","SubSys=Shop, Group=Rad, Device=Vault")

dbLoadRecords("db/Rad/RadiationMonitor.vdb","SubSys=Shop, Group=Rad, Device=Iso, ReadMSG=read0001Iso, DeviceName=ConsoleMoxa, ProtoFile=adm606M.proto")

dbLoadRecords("db/Rad/RadiationMonitorLogic.vdb","SubSys=Shop, Group=Rad, Device=Iso")







#For Communication with the PID COntroller in the pump room

dbLoadRecords("db/Cooling/PIDControlMonitor.vdb","SubSys=Shop, Group=Cooling, Device=PID, ReadMSG=readCNi853Water, DeviceName=shopComm, ProtoFile=CNi853.proto")






## Load record instances

dbLoadRecords("db/MonitorAlerts.vdb","SubSys=Shop")

dbLoadRecords("db/IocHeartbeat.vdb","SubSys=Shop")










# Set the TRACEIO_ESCAPE and ASYN_TRACEIO_HEX bits
#asynSetTraceIOMask(adm606MVault,0,6) 

# Turn on ASYN_TRACEIO_DRIVER and ASYN_TRACE_ERROR
#asynSetTraceMask(adm606MVault,0,9)

# Set the TRACEIO_ESCAPE and ASYN_TRACEIO_HEX bits
#asynSetTraceIOMask(ConsoleMoxa,0,6) 

# Turn on ASYN_TRACEIO_DRIVER and ASYN_TRACE_ERROR
#asynSetTraceMask(ConsoleMoxa,0,9)




cd ${TOP}/iocBoot/${IOC}



iocInit()

