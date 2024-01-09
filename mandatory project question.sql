use ig_clone;

-- task 1 
-- How many times does the average user post?
select avg(post_count) as average_posts_per_user
from (
    select u.id, u.username, COUNT(p.image_url) as post_count -- count post then avg of count 
    from users u
    join photos p on u.id = p.user_id
    group by u.id, u.username
) user_post_counts;

-- task 2-- finding top 5 most used tags
with cte1 as
 (
select tag_id,count(tag_id) over(order by count(tag_id) desc) as count1 from photo_tags group by tag_id limit 5 -- counting tags sort limit 5
)select tag_name from tags t join cte1 c on c.tag_id=t.id; 

-- task 3
-- Find users who have liked every single photo on the site.
select * from likes;
select * from photos;
with cte1 as
(
select user_id,count(photo_id) as count from likes group by user_id order by count(photo_id) desc -- how many photos user liked
),cte2 as 
(
select count(id) as count from photos -- count total photos 
)select user_id from cte1 c join cte2 ca on c.count=ca.count order by user_id; 

-- task 4--Retrieve a list of users along with their usernames and the rank of their account creation
-- ordered by the creation date in ascending order.

select username,rank() over(order by created_at asc) as rank_user from users;

-- task 5--List the comments made on photos with their comment texts, photo URLs,
 -- and usernames of users who posted the comments. Include the comment count for each photo
 
 select * from comments;
 select * from users;
 select * from photos;
 with cte as (
 select u.username,c.comment_text,c.photo_id,c.user_id,c.id,p.image_url 
 from comments c  -- three table join users,photos,comments
 join users u on c.user_id=u.id 
 join photos p on p.id=c.photo_id order by user_id
 ) select comment_text,image_url,username,count(photo_id) over(partition by photo_id) as count from  cte; -- count comment on each photo
  

-- task 6--For each tag, show the tag name and the number of photos associated with that tag. 
-- Rank the tags by the number of photos in descending order.
-- select * from tags;select * from photo_tags;select * from photos;
with cte1 as (
select *,count(tag_id) over (partition by tag_id ) as count_photos from photo_tags -- count tags 
),cte2 as 
(
select * from cte1 c join tags t on c.tag_id=t.id -- join tags,photo tags table 
),cte3 as
(
select distinct(tag_name),count_photos from cte2
)
select count_photos,tag_name,rank() over (order by count_photos desc)  as rank_1 from cte3; -- rank1 based on count desc


-- task 7
-- List the usernames of users who have posted photos along with the count of photos they have posted.
--  Rank them by the number of photos in descending order.
select * from users;
select * from photos;
with cte as 
(
select distinct(user_id),count(user_id) over (partition by user_id ) as count from photos order by count desc -- count photos posted
)select u.username,c.count,rank() over (order by c.count desc) as rank_1 from cte c join users u on u.id=c.user_id;-- rank based on count desc 

-- task 8
-- Display the username of each user along with the creation date of their first posted photo 
-- and the creation date of their next posted photo.
select * from users;
select * from photos;
with cte as
(
select u.username,p.created_at from photos p join users u on p.user_id=u.id -- join photos,users table
),cte2 as 
(
select *,first_value(created_at) over(order by created_at) as first_posted from cte -- fisrt creation date
),cte3 as
(
select * ,row_number() over (partition by username order by first_posted) as first_posted_1 from cte2 -- row number for 1 st user
),cte4 as 
(
select *,lead(created_at) over(order by created_at) as next_posted_photo from cte3 where first_posted_1=1 
)select username,first_posted,next_posted_photo from cte4;
-- task 9
-- For each comment, show the comment text, the username of the commenter,
-- and the comment text of the previous comment made on the same photo.
select * from comments;
select * from users;

with cte as 
(
select u.username,c.comment_text,c.photo_id from comments c join users u on u.id=c.user_id order by photo_id -- join comments,users 
)select *,lag(comment_text) over(partition by photo_id) as previous_comment from cte; -- lag function

-- task 10
-- Show the username of each user along with the number of photos they have posted and 
-- the number of photos posted by the user before them and after them, based on the creation date.
select * from users;
select * from photos;
with cte as 
(
select p.image_url,p.user_id,u.username,p.created_at from users u join photos p on p.user_id=u.id -- join users,photos
),cte2 as 
(
select username,created_at,count(user_id) over (partition by user_id order by created_at) as count from cte -- count posted photos
),cte3 as 
(
select distinct(username),count,created_at from cte2
)
select username,count,lead(count) over(order by created_at) as next_count,lag(count) over (order by created_at) as prev_count from cte3 ;
