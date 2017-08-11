function [i,g]=sumarization(tit,tex)
T=tit; %titulo
K=fileread(tex); %cuerpo del texto
s=extrationP(K); %extraccion de caracteristicas 
[i,g]=genetic(s,T); 
p='';
for j=1:length(i)
    if i(j)==1
      p=strcat(p,cell2mat(s(j)));
    end   
end
disp(p);

end
%extraccion de parrafos 
function kP=extrationP(K)
init=1;
idx = strfind(K,'.');
    for i=1:length(idx)
     kP(i)=cellstr(K(init:idx(i)));  
    init=idx(i)+1;
    end
end

function [ind,g]=genetic(q,t)
%Generación poblacion inicial con individuos con longitud K donde K es el
%numero de parrafos en el texto.
maxIter=1000;
sizePob=200;
lengP=length(q);
pobinit=randi([0,1],sizePob,lengP);
selectP=zeros(sizePob*.50,lengP);
fr=zeros(sizePob,1);
pl=zeros(10,1);
%fitness(q,t,);
for i=1:10
        %evaluacion de la poblacion inicial
        for j=1:sizePob
           fr(j)=fitness(q,t,pobinit(j,:));
        end
        
        %fase de selccion tipo ruleta
        fr=fr/sum(fr);
        for k=1:sizePob*.50
           a=rand;
           sig=0;
            for j=1:sizePob
                sig=sig+fr(j);
                if sig>a
                    selectP(k,:)=pobinit(j,:);
                    break;
                end
            end
        end   
        
        %cruza en un punto
        lenS=length(selectP);
        childrens=zeros(lenS,lengP);
        for j=1:2:lenS
            a=randi([2,lengP-1],1,1);     
            s1=horzcat(selectP(j,1:a),selectP(j+1,a+1:end));
            s2=horzcat(selectP(j+1,1:a),selectP(j,a+1:end));
            childrens(j,:)=s1;
            childrens(j+1,:)=s2;
        end
     
    
  %mutacion 
  U=5;%numero de mutaciones por array
        len=length(childrens);
       for z=1:U
            a=randi([1,sizePob*.50],1,1);
            mut=selectP(a,:);
           for h=1:3
               a=randi([1,lengP],1,1);
                if(mut(a)==0)
                    mut(a)=1;
                else
                    mut(a)=0;
                end
           end 
        childrens(len+z,:)=mut;
       end
    len=length(childrens);
    
    for n=1:len
        pobinit(sizePob+n,:)=childrens(n,:);
    end  
    
    %evaluacion
    temp=pobinit;
    for y=1:length(pobinit(:,1))
       f=fitness(q,t,temp(y,:));
       pobinit(y,lengP+1)=f;
    end
    
    temp=zeros(10,lengP);
    %sort poblation
    sortPop=sortrows(pobinit,lengP+1);
    sortPop=rot90(sortPop,2);
    sortPop= fliplr(sortPop);
    for h=1:sizePob
        temp(h,:)=sortPop(h,1:lengP);
    end
    
    pobinit=temp;
    pl(i)=sortPop(i,lengP+1);
end
    ind=pobinit(1,:);
    g=pl;
    g
end

%Evaluación de las restricciones 
function fit=fitness(K,t,kp)
tot=0;
lengP=length(kp);

%Constraint 1 evaluar si esta el ultimo o el primer parrafo
if kp(1)==1 
tot=tot+0.5;
end
if kp(end)==1 
tot=tot+0.5;
end
U=80;
for i=1:lengP
    if kp(i)==1
        %Constraint 2 evaluar si esta el titulo en los parrafos prpuestos
        if(~isempty(strfind(K,t)))
            tot=tot+1;
        else
            tot=tot-0.5;
        end
        %Constraint 3 evaluar si el parrafo seleccionado es apto por su longitud,
         %umbral propusto 80 caracteres minimo.
        if(length(cell2mat(K(i)))>U)
          tot=tot+0.5;
        end 
         %Constraint 4 evaluar el numero de mayusculas por palabras 
        y=1;
        P=cell2mat(K(i));
        idxspace=strfind(P,' ');
        for j=1:length(idxspace)
        p=P(y:idxspace(j));
        y=idxspace(j)+1;
        tu=isstrprop(p,'upper');
        if(sum(tu)>1)
            tot=tot+1;
        else
            tot=tot-0.1;
        end
        end
         %Constraint 5 si no tiene pronobres tales (tu,el,ella,ellos,ustedes, nosotros)
         pro={'tu','el','ella','ellos','ustedes','nosotros'};
         for m=1:length(pro)
         P=cell2mat(K(i));
         if(isempty(strfind(P,pro(m))))
             tot=tot+1;
         else
             tot=tot-0.5;
         end
         end 
    end
end
fit=tot;
end


