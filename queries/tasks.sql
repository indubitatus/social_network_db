-- 1) Для указанного пользователя найти всех друзей его друзей 
SELECT surname, name FROM users INNER JOIN 
	(SELECT DISTINCT id_user1 FROM friendship INNER JOIN 
		(SELECT id_user2 FROM friendship INNER JOIN 
			users ON friendship.id_user1=users.phone_number 
			WHERE users.name = 'Андрей' AND users.surname = 'Попов') AS friends 
		ON friendship.id_user2 = friends.id_user2) AS friends_friends
	ON users.phone_number = friends_friends.id_user1

-- 2) Для указанного пользователя найти таких пользователей, которые не являются друзьями, но учились в одно время хотя бы в одном учебном заведении и имеют общих друзей

CREATE TEMP TABLE study_not_friends ON COMMIT DROP AS 
SELECT id_user, id_institution, date_admission, date_graduation FROM usersstudy INNER JOIN
	(SELECT phone_number FROM users 
		EXCEPT SELECT id_user2 FROM friendship INNER JOIN 
			users ON friendship.id_user1=users.phone_number 
		 	WHERE users.name = 'Андрей' AND users.surname = 'Попов'	
		EXCEPT SELECT phone_number FROM users 
	 		WHERE users.name = 'Андрей' AND users.surname = 'Попов') AS not_friends
	ON not_friends.phone_number = usersstudy.id_user;

CREATE TEMP TABLE user_study ON COMMIT DROP AS
SELECT id_institution, date_admission, date_graduation FROM usersstudy INNER JOIN 
	users ON usersstudy.id_user=users.phone_number 
	WHERE users.name = 'Андрей' AND users.surname = 'Попов';

CREATE TEMP TABLE user_friends ON COMMIT DROP AS
SELECT id_user2 FROM friendship JOIN 
	users ON friendship.id_user1=users.phone_number 
	WHERE users.name = 'Андрей' AND users.surname = 'Попов';		

SELECT surname, name FROM users INNER JOIN
	(SELECT id_user1 FROM user_friends INNER JOIN 
		(SELECT id_user1, id_user2 FROM friendship INNER JOIN 
			(SELECT id_user FROM study_not_friends INNER JOIN 
			 	user_study ON study_not_friends.id_institution=user_study.id_institution
				WHERE (user_study.date_admission <= study_not_friends.date_admission 
					AND study_not_friends.date_admission <= user_study.date_graduation) OR
					(study_not_friends.date_admission <= user_study.date_admission 
					AND user_study.date_admission <= study_not_friends.date_graduation)) AS same_institution
			ON friendship.id_user1=same_institution.id_user) AS friends
		ON user_friends.id_user2=friends.id_user2) AS common_friends
	ON users.phone_number=common_friends.id_user1

-- 3) Найти таких пользователей, которые одновременно учились и работали

SELECT surname, name FROM users INNER JOIN
	(SELECT userswork.id_user FROM userswork
		INNER JOIN usersstudy ON userswork.id_user=usersstudy.id_user
		WHERE date_start <= date_graduation AND date_admission <= date_end) AS work_and_study 
	ON users.phone_number = work_and_study.id_user

-- 4) Найти такие учебные заведения, которые в указанный год закончили наибольшее число пользователей; в указанный год училось наибольшее число пользователей

-- а) 
CREATE TEMP TABLE institution_by_year ON COMMIT DROP AS
SELECT id_institution FROM usersstudy WHERE 
	EXTRACT(YEAR FROM date_graduation) = '2019';

CREATE TEMP TABLE count_graduates ON COMMIT DROP AS 
SELECT *, COUNT(*) AS cnt FROM institution_by_year GROUP BY institution_by_year.id_institution;

CREATE TEMP TABLE max_count_graduates ON COMMIT DROP AS SELECT MAX(cnt) FROM count_graduates;

SELECT name FROM study INNER JOIN 
	(SELECT id_institution FROM (count_graduates CROSS JOIN max_count_graduates) 
	WHERE max_count_graduates.max = count_graduates.cnt) AS institution ON study.id_institution = institution.id_institution

-- б) 

CREATE TEMP TABLE institution_by_year ON COMMIT DROP AS
SELECT id_institution FROM usersstudy WHERE 
	EXTRACT(YEAR FROM date_admission) <= '2019' AND '2019' <= EXTRACT(YEAR FROM date_graduation);

CREATE TEMP TABLE count_graduates ON COMMIT DROP AS 
SELECT *, COUNT(*) AS cnt FROM institution_by_year GROUP BY institution_by_year.id_institution;

CREATE TEMP TABLE max_count_graduates ON COMMIT DROP AS SELECT MAX(cnt) FROM count_graduates;

SELECT name FROM study INNER JOIN 
	(SELECT id_institution FROM (count_graduates CROSS JOIN max_count_graduates) 
	WHERE max_count_graduates.max = count_graduates.cnt) AS institution ON study.id_institution = institution.id_institution

