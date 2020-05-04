/ save csv - within lambda
`:data.csv 0:.h.tx[`csv;tab];

/ tab to html

tabToHtml:{ [tab]
  prep:{"\n",.h.htac[`tr;(`align`bgcolor!`left`white)] raze (.h.htc[`th]string@) each cols x};
  .h.htac[`table;`border`cellspacing`cellpadding`bordercolor!(1;0;2;"#999999");prep tab]
  };

/ toHtml tabToHtml t
toHtml:{
    style:"\n" sv ("body {background-color: powderblue;}";"h1   {color: blue;}";"p    {color: red;}");
    .h.htc[`html].h.htc[`head;.h.htc[`style]style],.h.htc[`body]x
    }

/ send html email
{ [to;from;msg]

/ Delete from table
.[t;();0#];

/ 

/ ipc send async

/ load from fifo



/ namespace lookup
.u.nsl:{ [namespace;searchString]
    namespace:$[`~namespace;.Q.dd'[`]key `;(),namespace];
    nsl:{ [ns;searchStr] enlist[ns]!f:enlist a where { [x;s] (lower x) like ("*",s,"*")}[;searchStr] each a:key ns}[;searchString];
    {where[0<count each x]# x}raze nsl peach namespace
    };

/ pivot table
.u.piv:{[t;k;p;v]
    / controls new columns names
    f:{[v;P]`${raze " " sv x} each string raze P[;0],'/:v,/:\:P[;1]};
     v:(),v; k:(),k; p:(),p; / make sure args are lists
     G:group flip k!(t:.Q.v t)k;
     F:group flip p!t p;
     key[G]!flip(C:f[v]P:flip value flip key F)!raze
      {[i;j;k;x;y]
       a:count[x]#x 0N;
       a[y]:x y;
       b:count[x]#0b;
       b[y]:1b;
       c:a i;
       c[k]:first'[a[j]@'where'[b j]];
       c}[I[;0];I J;J:where 1<>count'[I:value G]]/:\:[t v;value F]
    };

.u.fSet:{(value x[0])[1] set' 1_x};
/ dateRange
.u.dtRange:{[s;e] s +til 1+e-s};
/ basic stripe function - anything stripped typically has 5 stripes
.u.stripes:{`$string[x],/:string 1 +til 5};
/ day of the week for date
.u.dow:{ [dt] `Sat`Sun`Mon`Tue`Wed`Thu`Fri mod[dt;7] };
/ preFix table columns, .e.g when comparing data from the same function in diff envs, pre data might be amended to have pre in the column name
.u.amendCols:{ [tab;keyCol;prefix] (keyCol,{.Q.dd[x]y}[;prefix] each (cols tab) except keyCol) xcol tab};
size:`long$sum'[lst] * count'[.z.W]%count'[lst:sublist[sample;]'[.z.W]];
 

 

callback:({neg[.z.w] ({`.t.tracker insert (x;y;.z.p;z)};.z.h;system["p"];"Complete")};`);

primCmd:({.log.info["running archival syncs cmd for: ", .Q.s x .cfg.host];.t.C:0;c:first value x .cfg.host;cc:count c;r:{.log.info["Syncing progress: ",string[.t.C],"/",string y];.util.callSystemRetry[x;20];.t.C+:1;}[;cc] each c;value y;.log.info "RSYNC COMPLETE!!"};primJob;callback);

.t.tracker:flip `host`port`time`msg!4#();

 

HDB check

(!) . flip((`date;dt);
           (`datePresent;dp);
           (`allTablesPresent;$[part in .Q.PV;all .util.exists each ` sv' (`$string flip[(.Q.PD;.Q.PV)] first where .Q.PV =part),/:.Q.pt;0b]);
           (`custPart;cust);
           (`sessions;$[cust;part;0Nd]);
           (`tabCounts;$[dp;kt!({@[{count get x};x;0]} each ` sv' (`$string flip[(.Q.PD;.Q.PV)] first where .Q.PV =part),/:kt);kt!count[kt]#0]);
           (`denaliInsCacheChk;$[`denali~.cfg.class;(first raze select max date from instrument)<=first raze select max date from instrumentCache;0b])
.s.partitionCounter:{ [cls;reg;dts;tabs;piv]
    // some predefined lookup tables by class use tab~` to set tabs as below for cls
    checkTabs:$[tabs~`;.sod.keyTablesByClass cls;checkTabs:(),tabs];
    //default to all tables if not keytables for class - last part of below to handle backfill
    if[checkTabs~`symbol$();checkTabs: exec table from .cfg.tables where db in enlist[first ` vs cls]];
    if[checkTabs~`symbol$();:"Please specify a table list as no tables for predefined for class: ",string cls];
            // this is for noms session based partitioning.
            qq:{ [tabs;dts] raze { [tabs;d]
                // below is to handle noms session based partitioning - for blueSKE/oscarChi - the date is set to the previous Sunday as they are 7 day sessions
                sdate:$[&[`noms~.cfg.class;not `ske~.cfg.region];$[.cfg.region in `blueSKE`oscarChicago;sessionMap[-[d;d mod 7]]`sessions;sessionMap[d]`sessions];d];
                if[13h=type .Q.PV;sdate:d:`month$d]; / datascope
                if[not count sdate;sdate:d];
                :{ [d;t;sd]
                    res:`date`env`host`port`class`region!(d;.cfg.env;.cfg.host;.cfg.port;.cfg.class;.cfg.region);
                    res[`sdate]:sd;
                    res[`tab]:t;
                    res[`Count]:@[{count get x};.Q.dd[.Q.par[.u.pl (.cfg.hdbRoot;.cfg.class;.cfg.region); sd; t]; `sym];0];
                    res[`missing]:0b;
                    res[`inMemory]:d in .Q.PV;
                    :res
                    }[d;;] .' tabs cross sdate;
            }[tabs;] each dts}[checkTabs;];
    res:.util.executeOnProcsWithOptions[`process`class`region`host!(`ms;cls;reg;`);(qq;(),dts);(::);1b];
    if[not piv;:raze res`return];
    d:update site:.util.getHostSite'[host],totalCount:sum each value[d] from d:.Q.id .s.piv[raze res`return;`env`host`date`sdate`region`class`inMemory;`tab;`Count];
    `date`sdate`class`region xasc update pctDiff:abs"F"$.Q.f[4;]each pctDiff from update pctDiff:({&[100*(x-max[x])%|[1;max[x]];100]};totalCount) fby ([]date;sdate;class;region) from d
    };
 

