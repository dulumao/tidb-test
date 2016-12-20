use test;
create table benchcount(id int primary key auto_increment,tidb_version varchar(120),tikv_version varchar(120),pd_version varchar(120),bench_avg_time Double);
create table benchkv(id int primary key auto_increment,tidb_version varchar(120),tikv_version varchar(120),pd_version varchar(120),bench_avg_time double);
create table oltp(id int primary key auto_increment,tidb varchar(120),tikv varchar(120),pd varchar(120),threads int,tps double,avg_latency double, approx99 double,time datetime);
