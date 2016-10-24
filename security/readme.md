mysqlgrants.bash


Listar todos los permisos de todos los usuarios en MySQL

    14 Octubre 2016 

    Bash script seguridad MySQL permisos 

El día de hoy tuve que auditar permisos en un servidor de bases de datos MySQL, 
y me encontré con la dificultad que el mismo no provee una herramienta o 
comando para volcar todos los permisos (grants) de todos los usuarios. 
Por ello me vi en la necesidad de desarrollar un pequeño script Bash para 
llevar a cabo esta simple tarea. Pequeño script al que luego le agregué alguna 
funcionalidad básica para realizar filtrado y formateo de la salida.



El comando MySQL SHOW GRANTS, vuelca las sentencias SQL necesarias 
para duplicar los privilegios otorgados a una cuenta de usuario MySQL. 
Su comportamiento es similar al del comando SHOW CREATE TABLE, que vuelca la sentencia necesarias para crear una tabla.

Sin embargo, la limitación que tiene el comando SHOW GRANTS, 
es que se debe especificar una cuenta de usuario, 
y no es posible volcar los grants para todos los usuarios definidos en el motor de bases de datos. 
Entonces, es necesario primero listar todos los usuarios, para luego obtener los grants de cada uno.

El script, el cual he decidido llamar "mysqlgrants", está publicado en mi repositorio de scripts en GitHub.

Al ser ejecutado sin parámetros (o con -h) muestra una breve ayuda:

root@linuxito:~# ./mysqlgrants.bash
Dump MySQL grants for all users.

Usage: ./mysqlgrants.bash -u USER [-p] [OPTIONS]

  -u USER          User for login.

Options:

  -h, --help       Show this help.
  -p               Ask for pasword.
  --all-privileges List users with all privileges on some database.
  --global         List users with some privilege on all databases.
  --root           List users with all privileges on all databases
                   (same as --all-privileges --global).

Para funcionar requiere una cuenta de usuario MySQL con privilegios de SELECT sobre la base de datos 'mysql' (generalmente 'root'):

root@linuxito:~# ./mysqlgrants.bash -u root -p
Enter password: 
GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY PASSWORD xxxx
GRANT USAGE ON *.* TO 'fulanito'@'%' IDENTIFIED BY PASSWORD xxxx
GRANT ALL PRIVILEGES ON `mydb`.* TO 'fulanito'@'%'
GRANT ALL PRIVILEGES ON *.* TO 'root'@'::1' IDENTIFIED BY PASSWORD xxxx
GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' IDENTIFIED BY PASSWORD xxxx
GRANT ALL PRIVILEGES ON *.* TO 'root'@'linuxito' IDENTIFIED BY PASSWORD xxxx
GRANT PROXY ON ''@'' TO 'root'@'linuxito' WITH GRANT OPTION
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY PASSWORD xxxx
GRANT PROXY ON ''@'' TO 'root'@'localhost' WITH GRANT OPTION

Por seguridad (en caso de correr el script como 'root', o un usuario que tenga privilegios SUPER), 
el script reemplaza los hashes de las contraseñas, en la salida, por la cadena "xxxx".

La opción --all-privileges lista aquellos usuarios que tengan ALL PRIVILEGES sobre alguna base de datos (junto con la base en cuestión):

root@linuxito:~# ./mysqlgrants.bash -u root -p --all-privileges
Enter password: 
USER                            ALL PRIVILEGES ON
'debian-sys-maint'@'localhost'  *.*
'fulanito'@'%'                  `mydb`.*
'root'@'::1'                    *.*
'root'@'127.0.0.1'              *.*
'root'@'linuxito'               *.*
'root'@'localhost'              *.*

La opción --global muestra aquellos usuarios con privilegios globales, 
es decir algún tipo de privilegio sobre todas las bases de datos (*.*):

root@linuxito:~# ./mysqlgrants.bash -u root -p --global
Enter password: 
GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY PASSWORD xxxx
GRANT USAGE ON *.* TO 'fulanito'@'%' IDENTIFIED BY PASSWORD xxxx
GRANT ALL PRIVILEGES ON *.* TO 'root'@'::1' IDENTIFIED BY PASSWORD xxxx
GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' IDENTIFIED BY PASSWORD xxxx
GRANT ALL PRIVILEGES ON *.* TO 'root'@'linuxito' IDENTIFIED BY PASSWORD xxxx
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY PASSWORD xxxx

La opción --root es equivalente a utilizar --all-privileges --global:

root@linuxito:~# ./mysqlgrants.bash -u root -p --root
Enter password: 
'debian-sys-maint'@'localhost'  *.*
'root'@'::1'                    *.*
'root'@'127.0.0.1'              *.*
'root'@'linuxito'               *.*
'root'@'localhost'              *.*

Este comando es útil para detectar rápidamente usuarios que tengan todos los privilegios sobre todas las tablas. 
Si en esta salida aparece algún usuario distinto a 'root', se deben encender todas las alarmas. 
Se trata de una intrusión, o de una configuración de permisos desastrosa, situación que puede ocurrir 
tranquilamente cuando se deja la administración de un servidor de bases de datos MySQL en manos de un inepto.

Esto fue lo que encontré en uno de los servidores de un cliente:

root@debian:~# ./mysqlgrants.bash -u root -p --all-privileges --global
Enter password: 
'debian-sys-maint'@'localhost'     *.*
'root'@'::1'                       *.*
'root'@'127.0.0.1'                 *.*
'root'@'debian'                    *.*
'root'@'localhost'                 *.*
'sultanito'@'%'                    *.*
'menganitodb'@'%'                  *.*
'test'@'%'                         *.*
'prueba'@'%'                       *.*
'prod_user'@'%'                    *.*
'borrar2016'@'%'                   *.*

Kill it with fire!!!
Conclusiones

No confundir ineptitud con ignorancia. Un ignorante (como quien escribe) se remite a manuales, guías, 
tutoriales, o cualquier otra fuente bibliográfica confiable que le sea de ayuda cuando se enfrenta a una tarea que desconoce. 
Se instruye para resolver la tarea de la mejor forma (correcta, eficiente y segura). 
Luego deja de ser completamente ignorante en esa cuestión o tarea en particular. 
Un inepto, por el contrario, simplemente aplica la funesta técnica de prueba y error, 
mezclada con un poco de copy&paste de comandos de dudosa procedencia. Los resultados en este último caso son terribles.

Por otro lado, ahora que traigo a colación el tema de copy&paste de comandos, 
jamás de los jamases peguen en sus consolas comandos copiados de este blog. 
Los comandos que aquí se incluyen se presentan de manera meramente ilustrativa, 
con el fin de instruir al lector. 
Incluso sus salidas están alteradas completamente para no divulgar detalles de los sistemas sujetos a ejemplo.

Para finalizar, las consecuencias de abaratar costos en recursos humanos dedicados a la administración de sistemas, 
backup y seguridad pueden tener consecuencias catastróficas. 
Un bug en un desarrollo de software en general se puede corregir (con esto no quiero decir que se debe abaratar costos en el desarrollo), 
pero la negligencia e ineptitud en cuestiones de infraestructura puede provocar pérdida de datos e incidentes de seguridad, 
los cuales pueden provocar considerables pérdidas de tiempo y dinero (y suelen tener consecuencias irreversibles e irreparables).
