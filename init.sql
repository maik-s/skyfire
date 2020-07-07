CREATE DATABASE IF NOT EXISTS pcsg;
USE pcsg;
create table IF NOT EXISTS xmlpcsg (
	id int auto_increment,
	parent varchar(100) not null,
	context varchar(500) not null,
	rule varchar(4000) not null,
	prob float not null,
	primary key(id)
);
GRANT ALL PRIVILEGES ON *.* TO 'skyfire'@'%';