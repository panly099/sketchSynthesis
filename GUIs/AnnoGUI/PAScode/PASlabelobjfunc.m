function PASlabelobjfunc(classlabel)
  global record numobjects boolwaitingforlabel

  record.objects(numobjects).label=classlabel;
  boolwaitingforlabel=0;
  fprintf('%s\n',classlabel);
return