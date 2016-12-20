
/*
 * create table order (
 * 	id int(20) not null auto_increment,
 *	user_id int(20)
 *	time datetime,
 *	type int(10),
 *	info varchar(255),
 *	primary key (`id`),
 *	key `time_idx` (`time`),
 * );
 *
 * select id from order where time > x and time < y ORDER BY user_id [desc];
 * select id from order where time > x and time < y ORDER BY id [desc];
 *
 */

package main
