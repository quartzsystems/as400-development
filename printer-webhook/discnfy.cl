             PGM        PARM(&STATUS &SPLF)
             DCL        &STATUS *CHAR 10
             DCL        &SPLF *CHAR 10
             DCL        &MBR *CHAR 10 VALUE('DISCOK')
             DCL        &STMF *CHAR 32 VALUE('/tmp/fullsave.txt')

             IF         COND(&STATUS *NE 'OK') THEN(CHGVAR &MBR +
                          'DISCFAIL')

             RMVLNK     OBJLNK(&STMF)
             MONMSG     MSGID(CPFA0A9)
             CRTPF      FILE(QTEMP/SPLOUT) RCDLEN(378) SIZE(*NOMAX)
             MONMSG     MSGID(CPF7302)
             CLRPFM     FILE(QTEMP/SPLOUT)
             CPYSPLF    FILE(&SPLF) TOFILE(QTEMP/SPLOUT) +
                          JOB(*) SPLNBR(*LAST) CTLCHAR(*NONE)
             MONMSG     MSGID(CPF0000)
             CPYTOSTMF  FROMMBR('/QSYS.LIB/QTEMP.LIB/SPLOUT.FILE/SPLO+
                          UT.MBR') TOSTMF(&STMF) STMFOPT(*REPLACE) +
                          STMFCODPAG(1208) ENDLINFMT(*LF)
             MONMSG     MSGID(CPF0000)

             CRTPF      FILE(QTEMP/FTPLOG) RCDLEN(240)
             MONMSG     MSGID(CPF7302)
             CLRPFM     FILE(QTEMP/FTPLOG)
             OVRDBF     FILE(INPUT) TOFILE(QSTOOLS/QFTPSRC) MBR(&MBR)
             OVRDBF     FILE(OUTPUT) TOFILE(QTEMP/FTPLOG)
             FTP        RMTSYS('10.42.20.32')
             MONMSG     MSGID(CPF0000)
             DLTOVR     FILE(INPUT OUTPUT)
             ENDPGM