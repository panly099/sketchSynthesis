function record=PASviewannotation(filename)
  PASdir='../data/PASCAL/';
  record=PASreadrecord(filename);
  numplots=1;
  for i=1:length(record.objects), 
    if (~isempty(record.objects(i).mask)), numplots=numplots+1; end;
  end;
  R=floor(sqrt(numplots));C=ceil(numplots/R);
  img=imread([PASdir,record.imgname]);
  aspectratio=record.imgsize(1)/record.imgsize(2);
  subplot(R,C,1);imagesc(img);axis off;box off;hold on;
  if (record.imgsize(3)==1), colormap(gray); end;
  %title(record.imgname);
  maskplot=2;
  for i=1:length(record.objects),
    subplot(R,C,1);
    drawbox(record.objects(i).bbox);
    if (~isempty(record.objects(i).polygon)), 
      drawpoly(record.objects(i).polygon);
    end;
    if (~isempty(record.objects(i).mask)), 
      mask=(imread([PASdir,record.objects(i).mask])==i);
      drawmaskboundary(mask);
      subplot(R,C,maskplot);imagesc(mask);axis off;box off;
      maskplot=maskplot+1;
    end;
  end;
  subplot(R,C,1);hold off;
  if (maskplot>2), 
    squeezeplots(R,C,maskplot-1,aspectratio,0.01); 
  else
    axis image;
  end;
return

function axh=squeezeplots(R,C,maxplotnum,aspectratio,minsep)
  maxsize=[1-(([C R]+1)*minsep)]./[C R];
  if (aspectratio>=1),
    alpha=min(maxsize(1),aspectratio*maxsize(2));
    newsize=[alpha alpha/aspectratio];
  else
    alpha=min(maxsize(1)/aspectratio,maxsize(2));
    newsize=[aspectratio*alpha alpha];
  end;
  dc=(1-(newsize(1)*C))/(C+1);
  dr=(1-(newsize(2)*R))/(R+1);
  
  set(gcf,'Units','Normalized');
  for r=R:-1:1,
    for c=1:C,
      plotnum=(r-1)*C+c;
      if (plotnum<=maxplotnum),
	left=dc*c+newsize(1)*(c-1);
	bottom=dr*(R+1-r)+newsize(2)*(R-r);
	newpos=[left bottom newsize];
	axh(plotnum)=subplot(R,C,plotnum);
	set(axh(plotnum),'Units','normalized');
	set(axh(plotnum),'Position',newpos);
      end;
    end;
  end;  
return

function drawmaskboundary(mask)
  if (length(unique(mask(:)))>2), PASerrmsg('Mask is not binary','');end;
  [R,C]=size(mask);
  mask=double(mask);
  minmask=min(mask(:));
  maxmask=max(mask(:));
  pmask=[minmask*ones(1,C);mask;minmask*ones(1,C)];
  pmask=[minmask*ones(R+2,1) pmask minmask*ones(R+2,1)];
  cmask=ones(3);
  boundary=filter2(cmask,pmask,'valid');
  boundary=(boundary>minmask) & (boundary<(sum(cmask(:))*maxmask));
  ind=find(boundary);
  [x,y]=meshgrid([1:C],[1:R]);
  ax=plot(x(ind),y(ind),'g.','LineWidth',5);
return

function drawbox(pts)
  line(pts([1 3 3 1 1]),pts([2 2 4 4 2]),'Color',[1 0 0],'LineWidth',5);
return

function drawpoly(pts)
  x=pts([1:2:end,1]);
  y=pts([2:2:end,2]);
  line(x,y,'Color','y','LineWidth',5);
return
