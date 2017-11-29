Simplified HASH how many of my friends are in nest years math class

I want to know how many of my friends will be in my
next semester math class. I also want to know
age and declared sex of all srudents.
Some of studenst may be trans-gender and I do not
want to embarass myself.

INPUTS
======

WORK.FRIENDS ( These are my closest school friends)

    1    James
    2    Jane
    3    Janet
    4    Jeffrey
    5    John
    6    Joyce
    7    Judy
    8    Roger
    9    Tami
  ...  ....


WORK.MATH_CLASS  Next years math class roster

  Math class roster is SASHELP.CLASS  total obs=19

    NAME       SEX    AGE    HEIGHT    WEIGHT

    Alfred      M      14     69.0      112.5
    Alice       F      13     56.5       84.0
    Barbara     F      13     65.3       98.0
    Carol       F      14     62.8      102.5
    Henry       M      14     63.5      102.5
  ....
    Thomas      M      11     57.5       85.0
    William     M      15     66.5      112.0


WORKING CODE
============

   data want;
      %utl_hash(
         roster        = math_class   /* roster pf math class */
        ,friends       = friends      /* dataset with list of my fiends */
        ,friends_key   = name         /* variable in friends dataset with my friends names */
        ,want          = age sex      /* what I want to age and sex of all math stdents */
        );
   run;quit;

OUTPUT
======

 WORK.WANT total obs=9

   Obs    NAME       SEX    AGE    FLAG

    1     James       M      12      1   * these friends are in next years math class
    2     Jane        F      12      1   ..
    3     Janet       F      15      1   ..
    4     Jeffrey     M      13      1   ..
    5     John        M      12      1   ..
    6     Joyce       F      11      1   ..
    7     Judy        F      14      1   ..

    8     Roger       F      14      0   * not in next years math class
    9     Tami        F      14      0

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

data math_class;
  set sashelp.class(keep=name age sex);
run;quit;

* list of my friends;
data friends;
  set sashelp.class(keep=name where=(name=:'J')) end=dne;
  output;
  if dne then do;
     name='Roger';output;
     name='Tami' ;output;
  end;
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

data want;
   %utl_hash(
      roster        = math_class   /* roster pf math class */
     ,friends       = friends      /* dataset with list of my fiends */
     ,friends_names = name         /* variable in friends dataset with my friends names */
     ,want          = age sex      /* what I want to age and sex of all math stdents */
     );
run;qyut;



Futher tests

* compound key;
data want;
   %utl_hash(
      roster        = math_class   /* roster pf math class */
     ,friends       = friends      /* dataset with list of my fiends */
     ,friends_key   = name sex     /* variable in friends dataset with my friends names */
     ,want          = sex age      /* what I want to age and sex of all math stdents */
     );
run;quit;

* numeric key;
data want;
   %utl_hash(
      roster        = math_class   /* roster pf math class */
     ,friends       = friends      /* dataset with list of my fiends */
     ,friends_key   = name age     /* variable in friends dataset with my friends names */
     ,want          = sex age      /* what I want to age and sex of all math stdents */
     );
run;quit;


%macro utl_hash(
    roster=         /* math class roster */
   ,friends_key=  /* list of friends_namess  for lookup */
   ,want=           /* list of space delimited variable to add to matched friends_names */
   ,friends=        /* master large dataset that holds all friends_names and age sex */
   );

   * Chang Chung;
   %put %sysfunc(ifc(%sysevalf(%superq(roster       )=,boolean) ,ERROR: Please Provide roster,));
   %put %sysfunc(ifc(%sysevalf(%superq(friends_key  )=,boolean) ,ERROR: Please Provide fiends key(s) ,));
   %put %sysfunc(ifc(%sysevalf(%superq(want         )=,boolean) ,ERROR: Please Provivde dataset with a list of friends ,));
   %put %sysfunc(ifc(%sysevalf(%superq(friends      )=,boolean) ,ERROR: Please Provide friends ,));

    %let res= %eval
    (
        %sysfunc(ifc(%sysevalf(%superq( roster       )=,boolean),1,0))
      + %sysfunc(ifc(%sysevalf(%superq( friends_key  )=,boolean),1,0))
      + %sysfunc(ifc(%sysevalf(%superq( want         )=,boolean),1,0))
      + %sysfunc(ifc(%sysevalf(%superq( friends      )=,boolean),1,0))
    );
    %if &res = 0 %then %do;
     %local idx ;
     if _n_=1 then do;
        drop rc;
        if _n_=0 then set &roster;
        declare hash hsh(dataset:"&roster");
          rc = hsh.definekey(
          %do idx=1 %to %eval(%sysfunc(countw(&friends_names))-1);
             "%scan(&friends_key,&idx)",
          %end;
          "%scan(&friends_key,&idx)"
          );
          %do idx=1 %to %sysfunc(countw(&want));
             rc = hsh.definedata("%scan(&want,&idx)");
          %end;
          rc = hsh.definedone();
      end;
      set &friends;
       rc = hsh.find();
       if rc then do;
          put  &friends_key " is not in my &roster " (&want) (= $ );
          flag=0;
       end;
     else do;
        put &friends_key " is in my &roster "  (&want) (= $ );
        flag=1;
    end;
    drop rc;
    run;
  %end;
  %else %do;
    %put "Unable to compile HASH object due to ERRORs above";
  %end;

%mend utl_hash;



