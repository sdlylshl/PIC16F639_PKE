#
# Generated Makefile - do not edit!
#
# Edit the Makefile in the project folder instead (../Makefile). Each target
# has a -pre and a -post target defined where you can add customized code.
#
# This makefile implements configuration specific macros and targets.


# Include project Makefile
ifeq "${IGNORE_LOCAL}" "TRUE"
# do not include local makefile. User is passing all local related variables already
else
include Makefile
# Include makefile containing local settings
ifeq "$(wildcard nbproject/Makefile-local-default.mk)" "nbproject/Makefile-local-default.mk"
include nbproject/Makefile-local-default.mk
endif
endif

# Environment
MKDIR=gnumkdir -p
RM=rm -f 
MV=mv 
CP=cp 

# Macros
CND_CONF=default
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
IMAGE_TYPE=debug
OUTPUT_SUFFIX=cof
DEBUGGABLE_SUFFIX=cof
FINAL_IMAGE=dist/${CND_CONF}/${IMAGE_TYPE}/PIC16F639_PKE.${IMAGE_TYPE}.${OUTPUT_SUFFIX}
else
IMAGE_TYPE=production
OUTPUT_SUFFIX=hex
DEBUGGABLE_SUFFIX=cof
FINAL_IMAGE=dist/${CND_CONF}/${IMAGE_TYPE}/PIC16F639_PKE.${IMAGE_TYPE}.${OUTPUT_SUFFIX}
endif

# Object Directory
OBJECTDIR=build/${CND_CONF}/${IMAGE_TYPE}

# Distribution Directory
DISTDIR=dist/${CND_CONF}/${IMAGE_TYPE}

# Source Files Quoted if spaced
SOURCEFILES_QUOTED_IF_SPACED=Source/Button_Handler.asm Source/DELAY.asm Source/EEPROM.asm Source/LF_pwm.asm Source/Message_Handler.asm Source/RF.asm Source/SPI.asm Source/Transponder_AFE.asm Source/Transponder_PIC16F639_Demo.asm

# Object Files Quoted if spaced
OBJECTFILES_QUOTED_IF_SPACED=${OBJECTDIR}/Source/Button_Handler.o ${OBJECTDIR}/Source/DELAY.o ${OBJECTDIR}/Source/EEPROM.o ${OBJECTDIR}/Source/LF_pwm.o ${OBJECTDIR}/Source/Message_Handler.o ${OBJECTDIR}/Source/RF.o ${OBJECTDIR}/Source/SPI.o ${OBJECTDIR}/Source/Transponder_AFE.o ${OBJECTDIR}/Source/Transponder_PIC16F639_Demo.o
POSSIBLE_DEPFILES=${OBJECTDIR}/Source/Button_Handler.o.d ${OBJECTDIR}/Source/DELAY.o.d ${OBJECTDIR}/Source/EEPROM.o.d ${OBJECTDIR}/Source/LF_pwm.o.d ${OBJECTDIR}/Source/Message_Handler.o.d ${OBJECTDIR}/Source/RF.o.d ${OBJECTDIR}/Source/SPI.o.d ${OBJECTDIR}/Source/Transponder_AFE.o.d ${OBJECTDIR}/Source/Transponder_PIC16F639_Demo.o.d

# Object Files
OBJECTFILES=${OBJECTDIR}/Source/Button_Handler.o ${OBJECTDIR}/Source/DELAY.o ${OBJECTDIR}/Source/EEPROM.o ${OBJECTDIR}/Source/LF_pwm.o ${OBJECTDIR}/Source/Message_Handler.o ${OBJECTDIR}/Source/RF.o ${OBJECTDIR}/Source/SPI.o ${OBJECTDIR}/Source/Transponder_AFE.o ${OBJECTDIR}/Source/Transponder_PIC16F639_Demo.o

# Source Files
SOURCEFILES=Source/Button_Handler.asm Source/DELAY.asm Source/EEPROM.asm Source/LF_pwm.asm Source/Message_Handler.asm Source/RF.asm Source/SPI.asm Source/Transponder_AFE.asm Source/Transponder_PIC16F639_Demo.asm


CFLAGS=
ASFLAGS=
LDLIBSOPTIONS=

############# Tool locations ##########################################
# If you copy a project from one host to another, the path where the  #
# compiler is installed may be different.                             #
# If you open this project with MPLAB X in the new host, this         #
# makefile will be regenerated and the paths will be corrected.       #
#######################################################################
# fixDeps replaces a bunch of sed/cat/printf statements that slow down the build
FIXDEPS=fixDeps

.build-conf:  ${BUILD_SUBPROJECTS}
ifneq ($(INFORMATION_MESSAGE), )
	@echo $(INFORMATION_MESSAGE)
endif
	${MAKE}  -f nbproject/Makefile-default.mk dist/${CND_CONF}/${IMAGE_TYPE}/PIC16F639_PKE.${IMAGE_TYPE}.${OUTPUT_SUFFIX}

MP_PROCESSOR_OPTION=16f639
MP_LINKER_DEBUG_OPTION= 
# ------------------------------------------------------------------------------------
# Rules for buildStep: assemble
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
${OBJECTDIR}/Source/Button_Handler.o: Source/Button_Handler.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/Source" 
	@${RM} ${OBJECTDIR}/Source/Button_Handler.o.d 
	@${RM} ${OBJECTDIR}/Source/Button_Handler.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/Source/Button_Handler.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -d__DEBUG  -q -p$(MP_PROCESSOR_OPTION)  -l\"${OBJECTDIR}/Source/Button_Handler.lst\" -e\"${OBJECTDIR}/Source/Button_Handler.err\" $(ASM_OPTIONS)   -o\"${OBJECTDIR}/Source/Button_Handler.o\" \"Source/Button_Handler.asm\" 
	@${DEP_GEN} -d "${OBJECTDIR}/Source/Button_Handler.o"
	@${FIXDEPS} "${OBJECTDIR}/Source/Button_Handler.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/Source/DELAY.o: Source/DELAY.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/Source" 
	@${RM} ${OBJECTDIR}/Source/DELAY.o.d 
	@${RM} ${OBJECTDIR}/Source/DELAY.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/Source/DELAY.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -d__DEBUG  -q -p$(MP_PROCESSOR_OPTION)  -l\"${OBJECTDIR}/Source/DELAY.lst\" -e\"${OBJECTDIR}/Source/DELAY.err\" $(ASM_OPTIONS)   -o\"${OBJECTDIR}/Source/DELAY.o\" \"Source/DELAY.asm\" 
	@${DEP_GEN} -d "${OBJECTDIR}/Source/DELAY.o"
	@${FIXDEPS} "${OBJECTDIR}/Source/DELAY.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/Source/EEPROM.o: Source/EEPROM.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/Source" 
	@${RM} ${OBJECTDIR}/Source/EEPROM.o.d 
	@${RM} ${OBJECTDIR}/Source/EEPROM.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/Source/EEPROM.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -d__DEBUG  -q -p$(MP_PROCESSOR_OPTION)  -l\"${OBJECTDIR}/Source/EEPROM.lst\" -e\"${OBJECTDIR}/Source/EEPROM.err\" $(ASM_OPTIONS)   -o\"${OBJECTDIR}/Source/EEPROM.o\" \"Source/EEPROM.asm\" 
	@${DEP_GEN} -d "${OBJECTDIR}/Source/EEPROM.o"
	@${FIXDEPS} "${OBJECTDIR}/Source/EEPROM.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/Source/LF_pwm.o: Source/LF_pwm.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/Source" 
	@${RM} ${OBJECTDIR}/Source/LF_pwm.o.d 
	@${RM} ${OBJECTDIR}/Source/LF_pwm.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/Source/LF_pwm.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -d__DEBUG  -q -p$(MP_PROCESSOR_OPTION)  -l\"${OBJECTDIR}/Source/LF_pwm.lst\" -e\"${OBJECTDIR}/Source/LF_pwm.err\" $(ASM_OPTIONS)   -o\"${OBJECTDIR}/Source/LF_pwm.o\" \"Source/LF_pwm.asm\" 
	@${DEP_GEN} -d "${OBJECTDIR}/Source/LF_pwm.o"
	@${FIXDEPS} "${OBJECTDIR}/Source/LF_pwm.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/Source/Message_Handler.o: Source/Message_Handler.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/Source" 
	@${RM} ${OBJECTDIR}/Source/Message_Handler.o.d 
	@${RM} ${OBJECTDIR}/Source/Message_Handler.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/Source/Message_Handler.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -d__DEBUG  -q -p$(MP_PROCESSOR_OPTION)  -l\"${OBJECTDIR}/Source/Message_Handler.lst\" -e\"${OBJECTDIR}/Source/Message_Handler.err\" $(ASM_OPTIONS)   -o\"${OBJECTDIR}/Source/Message_Handler.o\" \"Source/Message_Handler.asm\" 
	@${DEP_GEN} -d "${OBJECTDIR}/Source/Message_Handler.o"
	@${FIXDEPS} "${OBJECTDIR}/Source/Message_Handler.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/Source/RF.o: Source/RF.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/Source" 
	@${RM} ${OBJECTDIR}/Source/RF.o.d 
	@${RM} ${OBJECTDIR}/Source/RF.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/Source/RF.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -d__DEBUG  -q -p$(MP_PROCESSOR_OPTION)  -l\"${OBJECTDIR}/Source/RF.lst\" -e\"${OBJECTDIR}/Source/RF.err\" $(ASM_OPTIONS)   -o\"${OBJECTDIR}/Source/RF.o\" \"Source/RF.asm\" 
	@${DEP_GEN} -d "${OBJECTDIR}/Source/RF.o"
	@${FIXDEPS} "${OBJECTDIR}/Source/RF.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/Source/SPI.o: Source/SPI.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/Source" 
	@${RM} ${OBJECTDIR}/Source/SPI.o.d 
	@${RM} ${OBJECTDIR}/Source/SPI.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/Source/SPI.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -d__DEBUG  -q -p$(MP_PROCESSOR_OPTION)  -l\"${OBJECTDIR}/Source/SPI.lst\" -e\"${OBJECTDIR}/Source/SPI.err\" $(ASM_OPTIONS)   -o\"${OBJECTDIR}/Source/SPI.o\" \"Source/SPI.asm\" 
	@${DEP_GEN} -d "${OBJECTDIR}/Source/SPI.o"
	@${FIXDEPS} "${OBJECTDIR}/Source/SPI.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/Source/Transponder_AFE.o: Source/Transponder_AFE.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/Source" 
	@${RM} ${OBJECTDIR}/Source/Transponder_AFE.o.d 
	@${RM} ${OBJECTDIR}/Source/Transponder_AFE.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/Source/Transponder_AFE.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -d__DEBUG  -q -p$(MP_PROCESSOR_OPTION)  -l\"${OBJECTDIR}/Source/Transponder_AFE.lst\" -e\"${OBJECTDIR}/Source/Transponder_AFE.err\" $(ASM_OPTIONS)   -o\"${OBJECTDIR}/Source/Transponder_AFE.o\" \"Source/Transponder_AFE.asm\" 
	@${DEP_GEN} -d "${OBJECTDIR}/Source/Transponder_AFE.o"
	@${FIXDEPS} "${OBJECTDIR}/Source/Transponder_AFE.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/Source/Transponder_PIC16F639_Demo.o: Source/Transponder_PIC16F639_Demo.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/Source" 
	@${RM} ${OBJECTDIR}/Source/Transponder_PIC16F639_Demo.o.d 
	@${RM} ${OBJECTDIR}/Source/Transponder_PIC16F639_Demo.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/Source/Transponder_PIC16F639_Demo.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -d__DEBUG  -q -p$(MP_PROCESSOR_OPTION)  -l\"${OBJECTDIR}/Source/Transponder_PIC16F639_Demo.lst\" -e\"${OBJECTDIR}/Source/Transponder_PIC16F639_Demo.err\" $(ASM_OPTIONS)   -o\"${OBJECTDIR}/Source/Transponder_PIC16F639_Demo.o\" \"Source/Transponder_PIC16F639_Demo.asm\" 
	@${DEP_GEN} -d "${OBJECTDIR}/Source/Transponder_PIC16F639_Demo.o"
	@${FIXDEPS} "${OBJECTDIR}/Source/Transponder_PIC16F639_Demo.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
else
${OBJECTDIR}/Source/Button_Handler.o: Source/Button_Handler.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/Source" 
	@${RM} ${OBJECTDIR}/Source/Button_Handler.o.d 
	@${RM} ${OBJECTDIR}/Source/Button_Handler.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/Source/Button_Handler.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -q -p$(MP_PROCESSOR_OPTION)  -l\"${OBJECTDIR}/Source/Button_Handler.lst\" -e\"${OBJECTDIR}/Source/Button_Handler.err\" $(ASM_OPTIONS)   -o\"${OBJECTDIR}/Source/Button_Handler.o\" \"Source/Button_Handler.asm\" 
	@${DEP_GEN} -d "${OBJECTDIR}/Source/Button_Handler.o"
	@${FIXDEPS} "${OBJECTDIR}/Source/Button_Handler.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/Source/DELAY.o: Source/DELAY.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/Source" 
	@${RM} ${OBJECTDIR}/Source/DELAY.o.d 
	@${RM} ${OBJECTDIR}/Source/DELAY.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/Source/DELAY.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -q -p$(MP_PROCESSOR_OPTION)  -l\"${OBJECTDIR}/Source/DELAY.lst\" -e\"${OBJECTDIR}/Source/DELAY.err\" $(ASM_OPTIONS)   -o\"${OBJECTDIR}/Source/DELAY.o\" \"Source/DELAY.asm\" 
	@${DEP_GEN} -d "${OBJECTDIR}/Source/DELAY.o"
	@${FIXDEPS} "${OBJECTDIR}/Source/DELAY.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/Source/EEPROM.o: Source/EEPROM.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/Source" 
	@${RM} ${OBJECTDIR}/Source/EEPROM.o.d 
	@${RM} ${OBJECTDIR}/Source/EEPROM.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/Source/EEPROM.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -q -p$(MP_PROCESSOR_OPTION)  -l\"${OBJECTDIR}/Source/EEPROM.lst\" -e\"${OBJECTDIR}/Source/EEPROM.err\" $(ASM_OPTIONS)   -o\"${OBJECTDIR}/Source/EEPROM.o\" \"Source/EEPROM.asm\" 
	@${DEP_GEN} -d "${OBJECTDIR}/Source/EEPROM.o"
	@${FIXDEPS} "${OBJECTDIR}/Source/EEPROM.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/Source/LF_pwm.o: Source/LF_pwm.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/Source" 
	@${RM} ${OBJECTDIR}/Source/LF_pwm.o.d 
	@${RM} ${OBJECTDIR}/Source/LF_pwm.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/Source/LF_pwm.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -q -p$(MP_PROCESSOR_OPTION)  -l\"${OBJECTDIR}/Source/LF_pwm.lst\" -e\"${OBJECTDIR}/Source/LF_pwm.err\" $(ASM_OPTIONS)   -o\"${OBJECTDIR}/Source/LF_pwm.o\" \"Source/LF_pwm.asm\" 
	@${DEP_GEN} -d "${OBJECTDIR}/Source/LF_pwm.o"
	@${FIXDEPS} "${OBJECTDIR}/Source/LF_pwm.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/Source/Message_Handler.o: Source/Message_Handler.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/Source" 
	@${RM} ${OBJECTDIR}/Source/Message_Handler.o.d 
	@${RM} ${OBJECTDIR}/Source/Message_Handler.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/Source/Message_Handler.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -q -p$(MP_PROCESSOR_OPTION)  -l\"${OBJECTDIR}/Source/Message_Handler.lst\" -e\"${OBJECTDIR}/Source/Message_Handler.err\" $(ASM_OPTIONS)   -o\"${OBJECTDIR}/Source/Message_Handler.o\" \"Source/Message_Handler.asm\" 
	@${DEP_GEN} -d "${OBJECTDIR}/Source/Message_Handler.o"
	@${FIXDEPS} "${OBJECTDIR}/Source/Message_Handler.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/Source/RF.o: Source/RF.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/Source" 
	@${RM} ${OBJECTDIR}/Source/RF.o.d 
	@${RM} ${OBJECTDIR}/Source/RF.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/Source/RF.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -q -p$(MP_PROCESSOR_OPTION)  -l\"${OBJECTDIR}/Source/RF.lst\" -e\"${OBJECTDIR}/Source/RF.err\" $(ASM_OPTIONS)   -o\"${OBJECTDIR}/Source/RF.o\" \"Source/RF.asm\" 
	@${DEP_GEN} -d "${OBJECTDIR}/Source/RF.o"
	@${FIXDEPS} "${OBJECTDIR}/Source/RF.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/Source/SPI.o: Source/SPI.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/Source" 
	@${RM} ${OBJECTDIR}/Source/SPI.o.d 
	@${RM} ${OBJECTDIR}/Source/SPI.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/Source/SPI.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -q -p$(MP_PROCESSOR_OPTION)  -l\"${OBJECTDIR}/Source/SPI.lst\" -e\"${OBJECTDIR}/Source/SPI.err\" $(ASM_OPTIONS)   -o\"${OBJECTDIR}/Source/SPI.o\" \"Source/SPI.asm\" 
	@${DEP_GEN} -d "${OBJECTDIR}/Source/SPI.o"
	@${FIXDEPS} "${OBJECTDIR}/Source/SPI.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/Source/Transponder_AFE.o: Source/Transponder_AFE.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/Source" 
	@${RM} ${OBJECTDIR}/Source/Transponder_AFE.o.d 
	@${RM} ${OBJECTDIR}/Source/Transponder_AFE.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/Source/Transponder_AFE.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -q -p$(MP_PROCESSOR_OPTION)  -l\"${OBJECTDIR}/Source/Transponder_AFE.lst\" -e\"${OBJECTDIR}/Source/Transponder_AFE.err\" $(ASM_OPTIONS)   -o\"${OBJECTDIR}/Source/Transponder_AFE.o\" \"Source/Transponder_AFE.asm\" 
	@${DEP_GEN} -d "${OBJECTDIR}/Source/Transponder_AFE.o"
	@${FIXDEPS} "${OBJECTDIR}/Source/Transponder_AFE.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/Source/Transponder_PIC16F639_Demo.o: Source/Transponder_PIC16F639_Demo.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/Source" 
	@${RM} ${OBJECTDIR}/Source/Transponder_PIC16F639_Demo.o.d 
	@${RM} ${OBJECTDIR}/Source/Transponder_PIC16F639_Demo.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/Source/Transponder_PIC16F639_Demo.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -q -p$(MP_PROCESSOR_OPTION)  -l\"${OBJECTDIR}/Source/Transponder_PIC16F639_Demo.lst\" -e\"${OBJECTDIR}/Source/Transponder_PIC16F639_Demo.err\" $(ASM_OPTIONS)   -o\"${OBJECTDIR}/Source/Transponder_PIC16F639_Demo.o\" \"Source/Transponder_PIC16F639_Demo.asm\" 
	@${DEP_GEN} -d "${OBJECTDIR}/Source/Transponder_PIC16F639_Demo.o"
	@${FIXDEPS} "${OBJECTDIR}/Source/Transponder_PIC16F639_Demo.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
endif

# ------------------------------------------------------------------------------------
# Rules for buildStep: link
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
dist/${CND_CONF}/${IMAGE_TYPE}/PIC16F639_PKE.${IMAGE_TYPE}.${OUTPUT_SUFFIX}: ${OBJECTFILES}  nbproject/Makefile-${CND_CONF}.mk    
	@${MKDIR} dist/${CND_CONF}/${IMAGE_TYPE} 
	${MP_LD} $(MP_EXTRA_LD_PRE)   -p$(MP_PROCESSOR_OPTION)  -w -x -u_DEBUG -z__ICD2RAM=1 -m"${DISTDIR}/${PROJECTNAME}.${IMAGE_TYPE}.map"   -z__MPLAB_BUILD=1  -z__MPLAB_DEBUG=1 $(MP_LINKER_DEBUG_OPTION) -odist/${CND_CONF}/${IMAGE_TYPE}/PIC16F639_PKE.${IMAGE_TYPE}.${OUTPUT_SUFFIX}  ${OBJECTFILES_QUOTED_IF_SPACED}     
else
dist/${CND_CONF}/${IMAGE_TYPE}/PIC16F639_PKE.${IMAGE_TYPE}.${OUTPUT_SUFFIX}: ${OBJECTFILES}  nbproject/Makefile-${CND_CONF}.mk   
	@${MKDIR} dist/${CND_CONF}/${IMAGE_TYPE} 
	${MP_LD} $(MP_EXTRA_LD_PRE)   -p$(MP_PROCESSOR_OPTION)  -w  -m"${DISTDIR}/${PROJECTNAME}.${IMAGE_TYPE}.map"   -z__MPLAB_BUILD=1  -odist/${CND_CONF}/${IMAGE_TYPE}/PIC16F639_PKE.${IMAGE_TYPE}.${DEBUGGABLE_SUFFIX}  ${OBJECTFILES_QUOTED_IF_SPACED}     
endif


# Subprojects
.build-subprojects:


# Subprojects
.clean-subprojects:

# Clean Targets
.clean-conf: ${CLEAN_SUBPROJECTS}
	${RM} -r build/default
	${RM} -r dist/default

# Enable dependency checking
.dep.inc: .depcheck-impl

DEPFILES=$(shell mplabwildcard ${POSSIBLE_DEPFILES})
ifneq (${DEPFILES},)
include ${DEPFILES}
endif
