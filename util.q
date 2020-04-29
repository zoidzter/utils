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


/ 

/ ipc send async

/ load from fifo

/ pivot table

/ namespace lookup
