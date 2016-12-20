/*
 * create table t (
 * 	id int(20) auto_increment,
 * 	user_id int(20),
 *	subject int(10),
 *	score float,
 *	primary key (`id`),
 *	key `used_idx` (`user_id`)
 * );
 *
 * select min/max/sum/avg/count(score) from t group by user_id;
 *
 */

package main
