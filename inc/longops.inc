IFNDEF LONGOPS_INC
LONGOPS_INC EQU LONGOPS_INC

XchgLongVal PROTO op1:QWORD, op2: QWORD

MovLongVal PROTO dest:QWORD, source: QWORD

AddLongVal PROTO op1:QWORD, op2: QWORD

SubLongVal PROTO op1:QWORD, op2: QWORD

CmpEqualLongVal PROTO op1:QWORD, op2: QWORD

CmpGreaterLongVal PROTO op1:QWORD, op2: QWORD

CmpLowerLongVal PROTO op1:QWORD, op2: QWORD

LongValToStdString PROTO target:QWORD, source:QWORD

IntToLongVal PROTO ival:DWORD, desc:QWORD

MultLongVal PROTO dest:QWORD, op1:QWORD, op2: QWORD

DoubleToLongVal PROTO dval:QWORD, desc:QWORD

DivideLongVal PROTO result:QWORD, reminder:QWORD, op1:QWORD, op2:QWORD

LongValToPower PROTO desc:QWORD, power:QWORD

AddLongValByMod PROTO op1:QWORD, op2: QWORD, opmod:QWORD

SubLongValByMod PROTO op1:QWORD, op2: QWORD, opmod:QWORD

MultLongValByMod PROTO op1:QWORD, op2: QWORD, opmod:QWORD

DivLongValByMod PROTO result:QWORD, reminder:QWORD, op1:QWORD, op2:QWORD, opmod:QWORD

LongValToPowerByMod PROTO desc:QWORD, power:QWORD, module:QWORD

LongValSquareRoot PROTO result:QWORD, operand:QWORD

ENDIF