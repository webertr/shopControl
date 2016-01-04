TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================

PROD_IOC = shop
DBD = shop.dbd

shop_DBD += commonInclude.dbd

# <name>_registerRecordDeviceDriver.cpp will be created from <name>.dbd
shop_SRCS += shop_registerRecordDeviceDriver.cpp
shop_SRCS += shopMain.cpp

shop_LIBS += asyn autosave calc modbus sscan std stream 


#===========================


shop_LIBS += $(EPICS_BASE_IOC_LIBS)
#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE
