@echo off
setlocal EnableDelayedExpansion

rem set in_path="d:\gps\in_msk\07.09.2020"
rem set in_path="d:\gps\in_msk"
rem set in_file_mask="*.log"
set out_path=out
goto -%1
echo Stop0
goto end
:-list
echo %2 %4 %5
set in_path="d:\gps\in_msk\full"
set in_file_mask="%2"
echo %in_file_mask%
dir %in_path%\%in_file_mask%
set start="%4"
set stop="%5"
echo %start% %stop%
:-
for /f "Tokens=1* Delims=" %%F in ('where /R %in_path% %in_file_mask%') do (
rem if not exist 
set full_out_path=%%~dpF%out_path%
set file_name=%%~nF
set out_file=%%~dpF%out_path%\%%~nF
set in_file=%%~dpnxF
rem echo !in_file! !full_out_path! !file_name! !out_file!)

if not exist !full_out_path! mkdir !full_out_path!
call go.cmd proc !in_file! !out_file!)

rem dpnx
goto end
:-proc
rem  in_file out_file
rem echo Start gpsbabel in
set f_in=%2
set f_out=%3_1.csv
echo f_in=%f_in% f_out=%f_out%
set cmd_path=%cd%
call bin\gpsbabel.cmd "-D1 -b %cmd_path%\bin\options_in -f %f_in% -F %f_out%"
pause
rem set f_in=%f_out%
rem set f_out=%3_1_.csv
rem echo f_in=%f_in% f_out=%f_out%
rem call bin\gpsbabel.cmd "-w -t -i unicsv -f %f_in% -x track,move=0w0d0h0m-1s -o unicsv -F %f_out%"

rem Перевод скорости из м/с в км/ч
set f_in=%f_out%
set f_out=%3_2.csv
echo f_in=%f_in% f_out=%f_out%
rem bin\csvfix eval -smq -ifn -hdr No,Latitude,Longitude,Altitude,Speed,Course,FIX,HDOP,VDOP,PDOP,Satellites,Date,Time,Speed2 -r 14,"int($5*36+0.5)/10" -o %f_out% %f_in%
bin\csvfix eval -smq -ifn -hdr No -r 14,"int($5*36+0.5)/10" %f_in%|bin\csvfix eval -smq -ifn -hdr No -r 15,"int($2)"|bin\csvfix eval -smq -ifn -hdr No -r 16,"int(($2-int($2))*60)"|bin\csvfix eval -smq -ifn -hdr No -r 17,"int((($2-int($2))*60-int(($2-int($2))*60))*60+0.5)"|bin\csvfix eval -smq -ifn -hdr No -r 18,"int($3)"|bin\csvfix eval -smq -ifn -hdr No -r 19,"int(($3-int($3))*60)"|bin\csvfix eval -smq -ifn -hdr No,Latitude,Longitude,Altitude,Speed,Course,FIX,HDOP,VDOP,PDOP,Satellites,Date,Time,Speed2 -r 20,"int((($3-int($3))*60-int(($3-int($3))*60))*60+0.5)" -o %f_out%
rem Формируем поле Name с отображением данных на карте снаружи метки
set f_in=%f_out%
set f_out=%3_3.csv
echo f_in=%f_in% f_out=%f_out%
bin\csvfix.exe printf -ifn -hdr No,Name -f 1,15:17,18:20,11:13,14 -fmt "\"%%d\",\"%%02d %%02d'%%02d,%%02d %%02d'%%02d,%%d,%%s,%%s,%%5.1f km/h\"" -o %f_out% %f_in%
set f_in=%3_2.csv
set f_out=%3_4.csv
echo f_in=%f_in% f_out=%f_out%
rem Удаляем вспомогательную колонку Name со скоростями в км/ч
bin\csvfix truncate -smq -n 13 -o %f_out% %f_in%
set f_in=%f_out%
set f_out=%3_5.csv
rem Соединяем тело с колонкой Name с отображением данных на карте снаружи метки
bin\csvfix join -osep ; -smq -f 1:1 -o %f_out% %f_in% %3_3.csv

echo Start gpsbabel out
set f_in=%f_out%
set f_out=%3.kml
rem gpsbabel -w -t -i unicsv -f D:/gps/in_msk/26.08.2019/out/20190826_043532_5.csv -x track,start=20190826024500,stop=20190826024630 -o kml,deficon=Speed:,floating=1,extrude=1,trackdirection=1,units=m -F D:/gps/in_msk/26.08.2019/out/20190826_043532.kml
rem call bin\gpsbabel.cmd "-w -t -i unicsv -f %f_in% -x track,start=20200907104600,stop=20200907105000 -o kml,deficon=Speed:,floating=1,extrude=1,trackdirection=1,units=m -F %f_out%"
rem call bin\gpsbabel.cmd "-w -t -i unicsv -f %f_in% -x track,speed,start=%start%,stop=%stop% -o kml,floating=1,trackdirection=1,units=m -F %f_out%"
call bin\gpsbabel.cmd "-w -t -i unicsv -f %f_in% -x track,start=%start%,stop=%stop% -o kml,deficon=Speed:,floating=1,trackdirection=1,units=m -F %f_out%"
rem ,move=0w0d0h0m-2s
:end
set in_path=
set in_file_mask=
set out_path=
set full_out_path=
set file_name=
set out_file=
set in_file=
set f_in=
set f_out=
set cmd_path=
set start=
set stop=
