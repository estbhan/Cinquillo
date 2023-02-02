{

El Cinquillo es un clásico juego de cartas, donde gana el que domina la mano
descartandose antes que cualquier otro jugador de la mesa. 

Copyright (C) 1994 @estbhan (Esteban H.N.) 

This program is free software: you can redistribute it and/or modify it under 
the terms of the GNU General Public License as published by the Free Software 
Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY 
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this 
program. If not, see <https://www.gnu.org/licenses/>.

}

uses
   crt,dos;

type

   {Definici¢n de la carta}
   carta = string[2];

   {Define el tipo enumerado 'palos'}
   palos = (oros,copas,espadas,bastos);
   pal = oros..bastos;

   mano = array [1..10] of carta; {Las 10 cartas de cada jugador}

   {Definici¢n del jugador, utilizada para repartir las cartas}
   jugador = record
                turno:integer;
                cart:mano;
             end;

   {Definici¢n del array que guardar  la baraja completa}
   cartas=array [1..40] of carta;

   {Definici¢n del tipo de variable que guardar  la mano de cartas ordenada}
   palo =  record
             car:mano;
             jug_inf,jug_sup:integer;
           end;

   {Definici¢n del tipo de variable que almacenar  un palo determinado con }
   {los valores de las jugadas inferior y superior correspondientes a dicho}
   {palo}
   jugada = array [oros..bastos] of palo;

   {Definici¢n del tablero}
   tablero = array [oros..bastos,1..10] of carta;

   {Definicion del ponderador}
   arreglo_10 = array [1..10] of integer;

   {Definici¢n del tipo de variable que guardar  las posiciones de las cartas}
   {que tenga un jugador, arriba o abajo del cinco para posteriormente       }
   {valorar la jugada}
   arreglo_6 = array [1..6] of integer;

   colores = array[oros..bastos] of integer;
{************************ PROCEDIMIENTOS Y FUNCIONES ***********************}

procedure retarda(ret:longint);
var
  retardo:longint;
begin
  retardo:=0;
  while retardo<ret do retardo:=retardo+1;
end;

procedure dibuja_carta( c:char;
                        a,b:integer);
  begin
    gotoxy(a,b);
    write(chr(201));
    write(chr(205));
    write(chr(187));
    gotoxy(a,b+1);
    write(chr(186));
    write(c);
    write(chr(186));
    gotoxy(a,b+2);
    write(chr(200));
    write(chr(205));
    write(chr(188));
  end;

procedure dibuja_espacio(a,b:integer);
begin
  textbackground(2);
  gotoxy(a,b);write('   ');
  gotoxy(a,b+1);write('   ');
  gotoxy(a,b+2);write('   ');
  textbackground(15);
end;

procedure dibuja_carta_oponente(a,b:integer);
begin
  textbackground(2);
  textcolor(5);
  gotoxy(a,b);
  write(chr(201),chr(205),chr(187));
  gotoxy(a,b+1);
  write(chr(186),chr(177),chr(186));
  gotoxy(a,b+2);
  write(chr(200),chr(205),chr(188));
end;


procedure localiza_carta( ca:carta;
                          a,b,parpadeo,numero:integer);
var
  c:char;

begin
  textbackground(15);
  if numero=1 then
    begin
      case ca[1] of
        'O':textcolor(14+parpadeo);
        'C':textcolor(4+parpadeo);
        'E':textcolor(1+parpadeo);
        'B':textcolor(10+parpadeo);
      end;
      c:=ca[2];
      if ca[2]='1' then c:='A';
      if ca[2]='8' then c:='S';
      if ca[2]='9' then c:='C';
      if ca[2]='A' then c:='R';
      if ca<>'' then dibuja_carta(c,a,b)
        else
          dibuja_espacio(a,b);
    end;
  if numero<>1 then
    if ca<>'' then dibuja_carta_oponente(a,b)
      else
        dibuja_espacio(a,b);
end;

procedure levanta_carta( a,i:integer;
                         c:carta);
begin
  case a of
    2:localiza_carta(c,70,10+(i-1)*3,0,1);
    3:localiza_carta(c,25+(i-1)*3,5,0,1);
    4:localiza_carta(c,10,10+(i-1)*3,0,1);
  end;
end;

procedure presenta_jugada( aa,bb,cc:integer;
                           d:mano);
var
  i,n:integer;

begin
  case aa of
    1:begin
        n:=0;
        gotoxy(bb,cc);
        for i:=1 to 10 do
          begin
            localiza_carta(d[i],bb+n,cc,0,aa);
            n:=n+3;
          end;
      end;

    2:begin
        n:=0;
        gotoxy(bb,cc);
        for i:=1 to 10 do
          begin
            localiza_carta(d[i],bb,cc+n,0,aa);
            n:=n+3;
          end;
      end;
    3:begin
        n:=0;
        gotoxy(bb,cc);
        for i:=1 to 10 do
          begin
            localiza_carta(d[i],bb+n,cc,0,aa);
            n:=n+3;
          end;
      end;
    4:begin
        n:=0;
        gotoxy(bb,cc);
        for i:=1 to 10 do
          begin
            localiza_carta(d[i],bb,cc+n,0,aa);
            n:=n+3;
          end;
      end;
  end;
end;

procedure limpia_jugador(var a,b,c,d:jugador);

var
  i:integer;
begin
  for i:=1 to 10 do
    begin
      a.cart[i]:='';
      b.cart[i]:='';
      c.cart[i]:='';
      d.cart[i]:='';
    end;
end;

procedure asigna_colores(var b:carta;
                         var color:integer);
  var
    a:colores;

  begin
    a[oros]:=14;
    a[copas]:=4;
    a[espadas]:=1;
    a[bastos]:=2;
    case b[1] of
      'O':color:=a[oros];
      'C':color:=a[copas];
      'E':color:=a[espadas];
      'B':color:=a[bastos];
    end;
  end;

procedure guarda(j:jugada;
                 var m:mano);
var
  a,i:integer;
  p:pal;

begin
  a:=0;
  for p:=oros to bastos do
    for i:=1 to 10 do
      if j[p].car[i]<>'' then
        begin
          a:=a+1;
          m[a]:=j[p].car[i];
        end;
end;

procedure limpia_mano(var a:mano);
  var
    i:integer;
  begin
    for i:=1 to 10 do
      a[i]:='';
  end;

procedure limpia_tablero(var t:tablero);
  var
    p:oros..bastos;
    a:integer;

  begin
    for p:=oros to bastos do
      for a:=1 to 10 do
        t[p,a]:='';
  end;

procedure limpia_jugada(var j1,j2,j3,j4:jugada);
  var
    p:oros..bastos;
    n:integer;

  begin
    for p:=oros to bastos do
    for n:=1 to 10 do
      begin
        j1[p].car[n]:='';j1[p].jug_inf:=100;j1[p].jug_sup:=100;
        j2[p].car[n]:='';j2[p].jug_inf:=100;j2[p].jug_sup:=100;
        j3[p].car[n]:='';j3[p].jug_inf:=100;j3[p].jug_sup:=100;
        j4[p].car[n]:='';j4[p].jug_inf:=100;j4[p].jug_sup:=100;
      end
  end;
procedure asigna_cartas(var a:cartas);
   begin
   a[1]:='O1';a[11]:='C1';a[21]:='E1';a[31]:='B1';
   a[2]:='O2';a[12]:='C2';a[22]:='E2';a[32]:='B2';
   a[3]:='O3';a[13]:='C3';a[23]:='E3';a[33]:='B3';
   a[4]:='O4';a[14]:='C4';a[24]:='E4';a[34]:='B4';
   a[5]:='O5';a[15]:='C5';a[25]:='E5';a[35]:='B5';
   a[6]:='O6';a[16]:='C6';a[26]:='E6';a[36]:='B6';
   a[7]:='O7';a[17]:='C7';a[27]:='E7';a[37]:='B7';
   a[8]:='O8';a[18]:='C8';a[28]:='E8';a[38]:='B8';
   a[9]:='O9';a[19]:='C9';a[29]:='E9';a[39]:='B9';
   a[10]:='OA';a[20]:='CA';a[30]:='EA';a[40]:='BA';
   end;

procedure asigna_cartas_para_pantalla(var a:cartas);

          {Para cuando haya que sacar las cartas por pantalla, es m s
          elegante este tipo de presentaci¢n}

   begin
   a[1]:='AO';a[11]:='AC';a[21]:='AE';a[31]:='AB';
   a[2]:='2O';a[12]:='2C';a[22]:='2E';a[32]:='2B';
   a[3]:='3O';a[13]:='3C';a[23]:='3E';a[33]:='3B';
   a[4]:='4O';a[14]:='4C';a[24]:='4E';a[34]:='4B';
   a[5]:='5O';a[15]:='5C';a[25]:='5E';a[35]:='5B';
   a[6]:='6O';a[16]:='6C';a[26]:='6E';a[36]:='6B';
   a[7]:='7O';a[17]:='7C';a[27]:='7E';a[37]:='7B';
   a[8]:='SO';a[18]:='SC';a[28]:='SE';a[38]:='SB';
   a[9]:='CO';a[19]:='CC';a[29]:='CE';a[39]:='CB';
   a[10]:='RO';a[20]:='RC';a[30]:='RE';a[40]:='RB';
   end;

function aleatorio:integer;
  var
     a:integer;
  begin
       repeat
         a:=trunc(100*random/2.5)+1 {Le sumo 1 para alcanzar las 40 cartas}
       until (a>0) and (a<41);
       aleatorio:=a;
  end;

function alea:integer;
{Esta funci¢n genera un n£mero pseudo-aleatorio  a  partir de un n£mero
extra¡do del reloj de MS-DOS}
  var
     a,b,c:integer;
     h,m,s,cs:word;
  begin
       clrscr;
       gettime(h,m,s,cs);
       b:=h+m+s+cs;
       c:=0;
       repeat
         c:=c+1;
         a:=trunc(trunc(100*random)/2.5)+1;
       until (a>0) and (a<41) and (c=b);
       alea:=a;
  end;

function ha_salido( var a:carta; {Carta a examinar}
                    b:cartas; {Variable donde se almacenar n las cartas
                              repartidas}
                    n:integer {N£mero de la £ltima carta repartida}):boolean;
   var
      c:boolean;
      i:integer;
   begin
      i:=0;
      repeat
        i:=i+1;
        if b[i]=a then c:=true else c:=false;
      until (i=n) or (c=true);
      ha_salido:=c;
   end;

procedure turno_inic( var a,b,c,d:jugador);
var
  i:integer;

begin
  for i:=1 to 10 do
    begin
      if a.cart[i]='O5' then
        begin
          a.turno:=1;
          b.turno:=2;
          c.turno:=3;
          d.turno:=4;
        end;
      if b.cart[i]='O5' then
        begin
          a.turno:=4;
          b.turno:=1;
          c.turno:=2;
          d.turno:=3;
        end;
      if c.cart[i]='O5' then
        begin
          a.turno:=3;
          b.turno:=4;
          c.turno:=1;
          d.turno:=2;
        end;
      if d.cart[i]='O5' then
        begin
          a.turno:=2;
          b.turno:=3;
          c.turno:=4;
          d.turno:=1;
        end;
    end;
end;

procedure asigna_turno( var a,b,c,d:jugador);

begin
   a.turno:=a.turno-1;if a.turno=0 then a.turno:=4;
   b.turno:=b.turno-1;if b.turno=0 then b.turno:=4;
   c.turno:=c.turno-1;if c.turno=0 then c.turno:=4;
   d.turno:=d.turno-1;if d.turno=0 then d.turno:=4;
end;

procedure reparte(var a,b,c,d:jugador;
                  partida:integer);
   var
      e,buffer:cartas;
      i,o,car,n:integer;
      no:boolean;

   begin
    asigna_cartas(e);
    car:=0;
    n:=0;
    for i:=1 to 4 do
       for o:=1 to 10 do
         begin
         if not((o=1) and (i=1)) then
             begin
               repeat
                 car:=aleatorio;
               until not ha_salido(e[car],buffer,n);
               n:=n+1;
               buffer[n]:=e[car];
             end
           else
             begin
               if partida=1 then car:=alea else car:=aleatorio;
               n:=1;
               buffer[n]:=e[car]
             end;{IF}
       case i of
         1:a.cart[o]:=e[car];
         2:b.cart[o]:=e[car];
         3:c.cart[o]:=e[car];
         4:d.cart[o]:=e[car];
       end;{Case}
       end;{1§ For}
   end;

function valor(a:char):integer;
var
  b,code:integer;
begin
  if a='A' then
    b:=10
  else
    val(a,b,code);
  valor:=b;
end;

procedure ordena_cartas(jug:jugador;
                        var jugad:jugada);
var
   a,c,code:integer;
   b:string[2];

begin
   for a:=1 to 10 do
     begin
       b:=jug.cart[a];
       if b[1]='O' then
          begin
            jugad[oros].car[valor(b[2])]:=b;
          end;
      if b[1]='C' then
          begin
            jugad[copas].car[valor(b[2])]:=b;
          end;
      if b[1]='E' then
          begin
            jugad[espadas].car[valor(b[2])]:=b;
          end;
      if b[1]='B' then
          begin
            jugad[bastos].car[valor(b[2])]:=b;
          end;
     end;
end;

procedure busca_carta(carti:carta;
                      e:mano;
                      var i:integer);
var
n:integer;

begin
      for n:=1 to 10 do
        if carti=e[n] then
           i:=n;
end;

procedure valora(var j:jugada;
                     v_sol,v_sal:arreglo_10;
                 var t:tablero);
var
  a,b,d,i,e:integer;
  c:arreglo_6;
  p:oros..bastos;

begin
  for p:=oros to bastos do {Recorremos los 4 palos}
  begin
    j[p].jug_inf:=100;
    j[p].jug_sup:=100;
    b:=0;
    for a:=1 to 6 do c[a]:=0; {Limpiamos el arreglo_6 para almacenar las   }
                              {posiciones de las distintas cartas desde el }
                              {cinco hacia abajo en orden descendente.     }
    i:=5;
    while (i>0) and (t[p,i]<>'') do  i:=i-1;
    if ((i>0) and (i<=5)) and (j[p].car[i]<>'') then {Si nos encontramos en    }
      begin                             {^}        {el rango de tirada 1..5 y}
        for a:=i downto 1 do            {|}        {adem s hay carta para    }
          begin {1}                     {|}        {tirar, se valora  la     }
            if j[p].car[a]<>'' then     {|}          {|} {jugada .           }
              begin {2}                 {|=----------=|}
                b:=b+1;  {Contabilizamos el n£mero de cartas para tirar en   }
                c[b]:=a  {esa jugada.                                        }
              end;  {2}
          end;  {1}
        if b=0 then j[p].jug_inf:=100 else  {Si no hay cartas, el valor de la}
                                            {jugada es 100. ­No hay jugada!  }

           if b=1 then j[p].jug_inf:=v_sol[c[b]] else{Si fuese una sola carta}
                                                     {el valor es directo.   }
              begin {3}
                d:=c[1];        {Ahora voy a examinar las cartas de la jugada}
                e:=0;           {para ver si son consecutivas o est n        }
                for a:=2 to b do                                  {salteadas.}
                  begin {4}
                    d:=d-c[a];
                    if d<>1 then e:=1 else
                       d:=c[a]; {Si fueran consecutivos 'e' ser¡a igual a 0}
                  end;  {4}
                if e=1 then {Entonces es que no son consecutivos}
                  begin {5}
                    j[p].jug_inf:=v_sal[c[1]];
                    for a:=2 to b do
                      j[p].jug_inf:=j[p].jug_inf-v_sal[c[a]];
                  end   {5}
                else {Si no se cumple la condici¢n anterior es que son}
                     {consecutivos, por lo tanto...}
                  j[p].jug_inf:=v_sol[c[b]]-(b-1);
              end;  {3}
      end {Del IF de i<>0}
    else
      j[p].jug_inf:=100;
    b:=0;
    for a:=1 to 6 do c[a]:=0; {Se limpia el arreglo_6 para almacenar las }
                              {nuevas posiciones de las cartas. En este  }
                              {caso en orden ascendente desde el cinco en}
                              {adelante.}
    i:=5;
    while ((i<11) and (t[p,i]<>'')) do  i:=i+1;
    if ((i>=5) and (i<11)) and (j[p].car[i]<>'')then {Esto es para ver si la  }
      begin                                       {carta puede ser o no ser}
        for a:=i to 10 do                         {colocada en el tablero. }
          begin
            if j[p].car[a]<>'' then {Aqu¡ se almacenan las posiciones de las}
              begin                 {distintas cartas que hayan desde el    }
                b:=b+1;             {cinco hacia arriba.                    }
                c[b]:=a {a=posici¢n de la carta}
              end;
          end;
        if b=0 then j[p].jug_sup:=100 else
           if b=1 then j[p].jug_sup:=v_sol[c[b]] else
              begin
                e:=0;
                d:=c[1];
                for a:=2 to b do
                  begin
                    d:=c[a]-d;
                    if d<>1 then e:=1 else
                      d:=c[a]; {Si no fueran consecutivos e ser¡a igual a 0}
                  end;
                if e=1 then {Entonces es que no son consecutivos}
                  begin
                    j[p].jug_sup:=v_sal[c[1]];
                    for a:=2 to b do
                      j[p].jug_sup:=j[p].jug_sup-v_sal[c[a]];

                  end
                else {Si no se cumple la condici¢n anterior es que son}
                     {consecutivos, por lo tanto...}
                  j[p].jug_sup:=v_sol[c[b]]-(b-1);
              end;
      end
    else
      j[p].jug_sup:=100; {Si la carta no pudiera ser colocada se le dar¡a}
                         {el valor 100 a la jugada para que de esa manera}
                         {no fuera ejecutada}
  end;
end;

function hay_cartas(j:jugada):boolean;
var
  p:oros..bastos;
  c:boolean;
  a,i:integer;
  b:mano;

begin
  a:=0;
  limpia_mano(b);
  for p:=oros to bastos do
    for i:=1 to 10 do
      if j[p].car[i]<>'' then
        begin
          a:=a+1;
          b[a]:=j[p].car[i];
        end;
  if b[1]='' then c:=false else c:=true;
  hay_cartas:=c;
end;

function hay_carta_para_tirar(t:tablero;
                              j:jugada):boolean;
var
  a:boolean;
  p:pal;
  i:integer;

begin
  a:=false;
  for p:=oros to bastos do
    begin
      i:=5;
      while ((t[p,i]<>'') and (i>0)) do i:=i-1;
      if ((j[p].car[i]<>'') and (i>0)) then a:=true;
      i:=5;
      while ((t[p,i]<>'') and (i<11)) do i:=i+1;
      if ((j[p].car[i]<>'') and (i<11)) then a:=true;
    end;
  hay_carta_para_tirar:=a;
end;

procedure tira_jugador(var jug:jugada;
                       var a:pal;
                       var c:integer;
                       var t:tablero;
                       var g:boolean;
                       numero:integer;
                       var e:mano;
                       partida:integer;
                       ret:longint);

var
  p:oros..bastos;
  b:integer;{b=0:No hay jugada  b=1:Jugada inferior  b=2:Jugada superior}
  d,n,i,color,x,y:integer;
  f:mano;
  retardo:longint;
  cinco:boolean;

begin
  a:=oros;
  c:=100;
  b:=0;
  cinco:=false;
  if partida=1 then
    for i:=1 to 10 do
      if e[i]='O5' then cinco:=true;
  if cinco then jug[oros].jug_inf:=-100;
  for p:=oros to bastos do        {Recorre los cuatro palos buscando la   }
    begin                         {jugada de menor valor.Dicha jugada es  }
      if jug[p].jug_inf < c then  {guardada por las variables auxiliares  }
        begin                     { a ( guarda el palo) y c ( guarda el   }
          a:=p;                   {valor de la jugada).                   }
          c:=jug[p].jug_inf;
          b:=1;
        end;
    end;
  for p:=oros to bastos do
    begin
      if jug[p].jug_sup < c then
        begin
          a:=p;
          c:=jug[p].jug_sup;
          b:=2;
        end;
    end;
  case b of
    1:begin
        d:=5;
        while jug[a].car[d]='' do d:=d-1;
        t[a,d]:=jug[a].car[d];
        busca_carta(jug[a].car[d],e,i);
        levanta_carta(numero,i,e[i]);
        retarda(ret);
        e[i]:='';
        jug[a].car[d]:='';
        jug[a].jug_inf:=100;
      end;
    2:begin
        d:=5;
        while jug[a].car[d]='' do d:=d+1;
        t[a,d]:=jug[a].car[d];
        busca_carta(jug[a].car[d],e,i);
        levanta_carta(numero,i,e[i]);
        retarda(ret);
        e[i]:='';
        jug[a].car[d]:='';
        jug[a].jug_sup:=100;
      end;
  end;
  if (b<>1) and (b<>2) then
    begin
      textcolor(15);
      case numero of
        2:begin
          x:=75;
          y:=25;
          end;
        3:begin
          x:=38;
          y:=10;
          end;
        4:begin
          x:=4;
          y:=25;
          end;
      end;
      textbackground(2);
      gotoxy(x,y);
      write('PASO');
      retarda(ret);
      gotoxy(x,y);
      write('    ');
    end;
  g:=not hay_cartas(jug);
  case numero of
    2:presenta_jugada(2,70,10,e);
    3:presenta_jugada(3,25,5,e);
    4:presenta_jugada(4,10,10,e);
  end;
end;

procedure tira_hombre(var ja:jugada;
                      var t:tablero;
                      var g:boolean;
                      var b:mano);
var
  p:oros..bastos;
  a,i,x,xx,ii,n,xxx,iii:integer;
  c:char;
  tirada,r_c:boolean;
  color:integer;

begin
  a:=0;
  g:=false;
  r_c:=hay_cartas(ja);
  presenta_jugada(1,25,42,b);{(Numero de Jugador,x,y,cartas}
  x:=25;
  n:=0;
  i:=1;
  while b[i]='' do
    i:=i+1;
  ii:=i;
  iii:=i;
  xxx:=x+(i-1)*3;
  localiza_carta(b[i],xxx,42,16,1);
  x:=xxx;
  xx:=x;
  textbackground(2);
  textcolor(5);
  gotoxy(55,43);
  write('  PASO'); {Escribo "PASO"}
  tirada:=false; {Mientras la tirada no se haga efectiva no se saldr  de}
  repeat         {este procedimiento. La tirada se hace efectiva bien   }
    repeat       {arrojando una carta o bien pasandose.                 }
       c:=readkey; {Lee el codigo de control}
       if c=#0 then
       begin
         c:=readkey; {Debido a que el primer codigo arrojado es #0 se lee}
                     {de nuevo.                                          }
           if c='M' then { M significa a la derecha =>}
             begin {2}
               xx:=xx+3; {Nos desplazamos a la derecha 5 espacios}
               ii:=ii+1; {Contabilizamos una carta mas}
               if xx>=50+5 then
                 begin {3}
                   xx:=50+5; {Si fuera mayor de 50 nos mantendr¡amos ah¡}
                   ii:=11;
                 end;  {3}
             end; {2}
           if c='K' then   {Si la tecla pulsada es la de la izquierda }
             begin {4}     {el c¢digo arrojado ser¡a la K}
               xx:=xx-3;   {Nos desplazamos a la izquierda 4 espacios}
               ii:=ii-1;   {Nos dirigimos a la carta inferior}
               if xx<xxx then
                 begin {5}
                   xx:=xxx; {Controlamos que no baje de 10}
                   ii:=iii;
                 end;  {5}
             end;  {4}
         if (x<>xx) and (xx<55) then
           begin
             if x<>55 then localiza_carta(b[i],x,42,0,1);
             localiza_carta(b[ii],xx,42,16,1);
             i:=ii;
             if x=55 then
               begin
                 textbackground(2);
                 gotoxy(28,50);
                 write('                        ');
                 gotoxy(x,43);{Si x=60  significa que nos encontrabamos en }
                 textcolor(5);{'PASO' por lo que ‚ste lo cambiamos de color}
                 write('  PASO');{indicando que ya no est  seleccionado.   }
               end;
             x:=xx;
           end;
         if (xx=55) and (x<>xx) then
           begin
             localiza_carta(b[i],x,42,0,1);
             gotoxy(xx,43);{en segundo lugar, cabiamos "PASO" de color con}
             textbackground(2);
             textcolor(15+16);{la pluma 5.                                  }
             write('  PASO');
             x:=xx;
           end;
       end;

    until  (ord(c)=13) and ((ii=11) or (b[ii]<>''));
    if hay_carta_para_tirar(t,ja) and (ii=11) then
      begin
        textbackground(2);
        textcolor(15);
        gotoxy(28,50);
        write('TIENES CARTA  PARA TIRAR');
        tirada:=false;
      end;
    if not hay_carta_para_tirar(t,ja) and (ii=11) then
      begin
        tirada:=true;
        textbackground(2);
        gotoxy(x,43);{Si ii=11  significa que nos encontramos en  }
        textcolor(5);{'PASO' por lo que ‚ste lo cambiamos de color}
        write('  PASO');{indicando que ya se seleccion¢.          }
      end;
    for p:=oros to bastos do  {Con este bucle pretendo localizar la carta}
      for i:=1 to 10 do       {seleccionada dentro de la variable "ja",  }
       begin                  {para borrarla del conjunto de cartas.     }
        if (ja[p].car[i]=b[ii]) and (ii<11) and (tirada=false) then
         begin
          if (i=5) or (i<5) and (t[p,i+1]<>'') or (i>5) and (t[p,i-1]<>'') then
             begin
               t[p,i]:=b[ii];  {Introducimos en el tablero la carta jugada.}
               ja[p].car[i]:=''; {Borramos la carta del conjunto de cartas}
               tirada:=true;
               b[ii]:='';     {del jugador humano.                     }
               textbackground(2);
               gotoxy(28,50);
               write('                        ');
               presenta_jugada(1,25,42,b);{(Numero de Jugador,x,y,cartas}
               if not hay_cartas(ja) then
                  g:=true;
               exit;
             end
          else
             begin
               textbackground(2);
               gotoxy(25,50);
               textcolor(15);
               write('­­ESA JUGADA NO SE PUEDE HACER!!');
               readkey;
               gotoxy(25,50);
               write('                                ');
               tirada:=false;
               x:=xx;
             end;
         end;
       end;
    i:=ii;
  until tirada;
end;

procedure realiza_la_tirada(a,b,c,d:integer;
                            var ja,jb,jc,jd:jugada;
                            tirada:integer;
                            var ganador:integer;
                            var t:tablero;
                            var m_1,m_2,m_3,m_4:mano;
                            partida:integer;
                            ret:longint);
var
  p:pal;
  aba_arr:integer;
  g:boolean;

begin
  g:=false;
  if tirada=a then tira_hombre(ja,t,g,m_1);
  if g then ganador:=1;g:=false;
  if tirada=b then tira_jugador(jb,p,aba_arr,t,g,2,m_2,partida,ret);
  if g then ganador:=2;g:=false;
  if tirada=c then tira_jugador(jc,p,aba_arr,t,g,3,m_3,partida,ret);
  if g then ganador:=3;g:=false;
  if tirada=d then tira_jugador(jd,p,aba_arr,t,g,4,m_4,partida,ret);
  if g then ganador:=4;g:=false;
end;

procedure valores_posicionales(var v_sol,v_sal:arreglo_10);
  begin
    v_sol[1]:=1;v_sol[2]:=2;v_sol[3]:=3;v_sol[4]:=4;v_sol[5]:=6;
    v_sol[6]:=5;v_sol[7]:=4;v_sol[8]:=3;v_sol[9]:=2;v_sol[10]:=1;
    v_sal[1]:=4;v_sal[2]:=3;v_sal[3]:=2;v_sal[4]:=1;v_sal[5]:=2;
    v_sal[6]:=1;v_sal[7]:=2;v_sal[8]:=3;v_sal[9]:=4;v_sal[10]:=5;
  end;

procedure ordena_cartas_sub_proc(jug1,jug2,jug3,jug4:jugador;
                                 var juga1,juga2,juga3,juga4:jugada);
begin
   ordena_cartas(jug1,juga1);
   ordena_cartas(jug2,juga2);
   ordena_cartas(jug3,juga3);
   ordena_cartas(jug4,juga4);
end;

procedure presenta_tablero (t:tablero);
var
  p:oros..bastos;
  a,i,c:integer;
  b:colores;
begin
  a:=15;
  for p:=oros to bastos do
    begin
      a:=a+10;
      c:=15;
      for i:=1 to 10 do
        begin
          if t[p,i]<>'' then
          begin
            localiza_carta(t[p,i],a,c,0,1);
          end;
          c:=c+2;
        end;
    end;
end;

procedure presenta_cartas(j1,j2,j3,j4:jugador);
var
  a:integer;

begin
  write('Jugador1:');
  for a:=1 to 10 do
     write(j1.cart[a],' ');
  writeln;
  write('Jugador2:');
  for a:=1 to 10 do
     write(j2.cart[a],' ');
  writeln;
  write('Jugador3:');
  for a:=1 to 10 do
     write(j3.cart[a],' ');
  writeln;
  write('Jugador4:');
  for a:=1 to 10 do
     write(j4.cart[a],' ');
end;

procedure presentacion;

begin
  textmode(3);
  textbackground(2);
  clrscr;
  textcolor(15);
  gotoxy(31,12);
  write('C I N Q U I L L O');
  gotoxy(22,20);
  write('Autor: Esteban Holgado Noda    ¸1994');
  readkey
end;

procedure velocidad(var ret:longint);

var
  a:char;
  i:integer;

begin
  clrscr;
  textcolor(15);
  gotoxy(31,2);
  write('VELOCIDAD DE JUEGO');
  gotoxy(6,24);
  write('UTILIZA LAS TECLAS DEL CURSOR [ARRIBA-ABAJO]');
  WRITE(' PARA VARIAR LA VELOCIDAD');
  i:=1;
  gotoxy(40,4);
  write(i);
  repeat
  a:=readkey;
   if a=#0 then
     begin
       a:=readkey;
       if a='H' then i:=i+1;
       if a='P' then i:=i-1;
       if i>5 then i:=5;
       if i<1 then i:=1;
       gotoxy(40,4);
       write(i);
     end;
  until ord(a)=13;
  case i of
    5:ret:=1000;
    4:ret:=10000;
    3:ret:=100000;
    2:ret:=1000000;
    1:ret:=2000000;
  end;
end;

{*************************** PROGRAMA PRINCIPAL ****************************}
var
   jug1,jug2,jug3,jug4:jugador;
   partida,ganador,tirada:integer;
   retardo,ret:longint;
   fin:char;
   juga1,juga2,juga3,juga4:jugada;
   i,tir:integer;{Contador}
   t:tablero;
   v_sol,v_sal:arreglo_10;
   p:oros..bastos;
   mano_1,mano_2,mano_3,mano_4:mano;
begin
   presentacion;
   velocidad(ret);
   textmode(259);
   partida:=1;
   {Valor de las cartas seg£n su posici¢n}
   valores_posicionales(v_sol,v_sal);
   limpia_jugada(juga1,juga2,juga3,juga4);
   limpia_jugador(jug1,jug2,jug3,jug4);
   reparte(jug1,jug2,jug3,jug4,partida);
   turno_inic(jug1,jug2,jug3,jug4);
   limpia_mano(mano_1);
   limpia_mano(mano_2);
   limpia_mano(mano_3);
   limpia_mano(mano_4);
   repeat
     textbackground(2);
     clrscr;
     textcolor(8);
     gotoxy(69,41);
     write('N§: 2');
     gotoxy(38,2);
     write('N§:3');
     gotoxy(9,41);
     write('N§: 4');
     ganador:=0;
     tir:=0;
     tirada:=1;
     limpia_tablero(t);
     if partida>1 then
       begin
         limpia_jugada(juga1,juga2,juga3,juga4);
         limpia_jugador(jug1,jug2,jug3,jug4);
         reparte(jug1,jug2,jug3,jug4,partida);
         asigna_turno(jug1,jug2,jug3,jug4);
         limpia_mano(mano_1);
         limpia_mano(mano_2);
         limpia_mano(mano_3);
         limpia_mano(mano_4);
       end;
     ordena_cartas_sub_proc(jug1,jug2,jug3,jug4,juga1,juga2,juga3,juga4);
     guarda(juga1,mano_1);
     guarda(juga2,mano_2);
     guarda(juga3,mano_3);
     guarda(juga4,mano_4);
     presenta_jugada(1,25,42,mano_1);{(Numero de Jugador,x,y,cartas}
     presenta_jugada(3,25,5,mano_2);
     presenta_jugada(2,70,10,mano_3);
     presenta_jugada(4,10,10,mano_4);
     repeat
      {valora(juga1,v_sol,v_sal,t);}
       valora(juga2,v_sol,v_sal,t);
       valora(juga3,v_sol,v_sal,t);
       valora(juga4,v_sol,v_sal,t);
       realiza_la_tirada(jug1.turno,jug2.turno,jug3.turno,jug4.turno,
                         juga1,juga2,juga3,juga4,tirada,ganador,t,mano_1,
                         mano_2,mano_3,mano_4,partida,ret);
       presenta_tablero(t);
       tir:=tir+1;
       tirada:=(tir mod 4)+1;
       retarda(ret);
     until ganador<>0;
     textbackground(2);
     textcolor(15);
     gotoxy(29,47);
     case ganador of
       1:begin
           gotoxy(27,47);
           writeln('­­ Has conseguido ganar !!');
         end;
       2:writeln('EL Ganador es el N§ :',ganador);
       3:writeln('EL Ganador es el N§ :',ganador);
       4:writeln('EL Ganador es el N§ :',ganador);
     end;
     repeat
       gotoxy(30,49);
       write('¨Otra partida (S/N)?');
       read(fin);
     until (fin='S') or (fin='N') or (fin='s') or (fin='n');
     partida:=partida+1;
   until (fin='N') or (fin='n'); {1§ REPEAT}
   textmode(3);
end.
