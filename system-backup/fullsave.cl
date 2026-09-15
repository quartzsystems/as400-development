             PGM
             DCL        VAR(&MSG) TYPE(*CHAR) LEN(256)
             DCL        VAR(&TRY) TYPE(*DEC) LEN(2 0) VALUE(0)
             OVRPRTF    FILE(QSYSPRT) MAXRCDS(*NOMAX) OVRSCOPE(*JOB)
             MONMSG     MSGID(CPF0000)

/* Verify valid tape before touching subsystems */
             VRYCFG     CFGOBJ(TAP01) CFGTYPE(*DEV) STATUS(*ON)
             MONMSG     MSGID(CPF0000)
             CHKTAP     DEV(TAP01)
             MONMSG     MSGID(CPF0000) EXEC(DO)
             SNDMSG     MSG('FULLSAVE ABORTED: No valid tape in +
                          TAP01') TOMSGQ(QSYSOPR)
             RETURN
             ENDDO

/* Let tape/inquiry messages answer themselves from WRKRPYLE */
/* Warn every signed-on workstation and gives them 5 minutes. */
             CHGJOB     INQMSGRPY(*SYSRPYL)
             SNDBRKMSG  MSG('FULLSAVE IMMINENT: Within 5 minutes') +
                          TOMSGQ(*ALLWS)
             MONMSG     MSGID(CPF0000)
             DLYJOB     DLY(300)

/* Takes system to restricted state. */
/* Ends TCP first and then every subsystem except QCTL.*/
             ENDTCP     OPTION(*IMMED)
             MONMSG     MSGID(CPF0000)
             DLYJOB     DLY(60)
             ENDSBS     SBS(*ALL) OPTION(*IMMED)
             MONMSG     MSGID(CPF0000)
             DLYJOB     DLY(180)

/* SAVSYS which requires restricted mode. */
/* it will fail if all subsystems are not ended. */
SAVSYSLP:
             SAVSYS     DEV(TAP01) ENDOPT(*LEAVE) CLEAR(*ALL) +
                          OUTPUT(*PRINT)
             MONMSG     MSGID(CPF0000) EXEC(DO)
             CHGVAR     VAR(&TRY) VALUE(&TRY + 1)
             IF         COND(&TRY *GT 30) THEN(GOTO CMDLBL(ERROR))
             ENDSBS     SBS(*ALL) OPTION(*IMMED)
             MONMSG     MSGID(CPF0000)
             DLYJOB     DLY(60)
             GOTO       CMDLBL(SAVSYSLP)
             ENDDO

/* Saves all non-system libraries. */
             SAVLIB     LIB(*NONSYS) DEV(TAP01) ENDOPT(*LEAVE) +
                          ACCPTH(*YES) OUTPUT(*PRINT)
             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(ERROR))

/* Saves all document library objects. */
             SAVDLO     DLO(*ALL) FLR(*ANY) DEV(TAP01) +
                          ENDOPT(*LEAVE) OUTPUT(*PRINT)
             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(ERROR))

/* Saves IFS root and omits QSYS.LIB and QDLS. */
             SAV        DEV('/QSYS.LIB/TAP01.DEVD') OBJ(('/*') +
                          ('/QSYS.LIB' *OMIT) ('/QDLS' *OMIT)) +
                          UPDHST(*YES) ENDOPT(*UNLOAD) OUTPUT(*PRINT)
             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(ERROR))

             SNDMSG     MSG('FULLSAVE: Completed normally') +
                          TOMSGQ(QSYSOPR)
             GOTO       CMDLBL(RESTART)

/* Saves error message and sends it to QSYSOPR. */
 ERROR:      RCVMSG     MSGTYPE(*EXCP) MSG(&MSG)
             MONMSG     MSGID(CPF0000)
             SNDMSG     MSG('FULLSAVE FAILED: ' *CAT &MSG) +
                          TOMSGQ(QSYSOPR)
             MONMSG     MSGID(CPF0000)

/* Brings the system back up after backup. */
 RESTART:    CALL       PGM(QSYS/QSTRUP)
             MONMSG     MSGID(CPF0000)
             STRTCP
             MONMSG     MSGID(CPF0000)
             DLYJOB     DLY(60)
             STRHOSTSVR SERVER(*ALL)
             MONMSG     MSGID(CPF0000)
             STRTCPSVR  SERVER(*ALL)
             MONMSG     MSGID(CPF0000)
             ENDPGM