-- We have a 
--     1. Machine learning binary classifier which takes as input an image and outputs the image quality score 
--        (from 0 to 1, where scores closer to 0 represent low-quality images, and scores closer to 1 represent high-quality images).
--     2. SQL table containing 1M unlabeled images. 
-- We run each of these images through our machine learning model to get float scores from 0 to 1 for each image.
-- We want to prepare a new training set with some of these unlabeled images. An example of unlabeled_image_predictions (1M rows) is shown below:

--|----------|----------|--
  | image_id |	score   |
--|----------|----------|--
  | 242	     | 0.23     |
--|----------|----------|--
  | 123	     | 0.92     |
--|----------|----------|--
  | 248	     | 0.88     |
--|----------|----------|--
  |    …	   | …        |
--|----------|----------|--

-- Our sampling strategy is to order the images in decreasing order of scores and sample every 3rd image starting with the first from the beginning until we get 10k positive samples. And we would like to do the same in the other direction, starting from the end to get 10k negative samples.
-- Task: Write a SQL query that performs this sampling and creates the expected output ordered by image_id with integer columns image_id, weak_label.
-- Feel free to develop in DB-Fiddle, your own SQL sandbox, or writing the query directly in your submission. If using DB-Fiddle with PostgresSQL v12 (set the database engine on the top-left), you may find this example input table of 50 rows useful (can be pasted into the “Schema SQL” text box). 
-- You may also find ROW_NUMBER() or helpers with similar functionality useful.

CREATE TABLE IF NOT EXISTS unlabeled_image_predictions (
  	image_id int,
  	score float
 );
 
TRUNCATE TABLE unlabeled_image_predictions;
INSERT INTO unlabeled_image_predictions (image_id, score) VALUES
  ('828','0.3149'), ('132','0.8823'), ('424','0.7790'), 
  ('809','0.1058'), ('439','0.3387'), ('823','0.3361'), 
  ('115','0.5309'), ('971','0.9871'), ('705','0.9892'), 
  ('906','0.8394'), ('609','0.5241'), ('219','0.7143'), 
  ('464','0.3674'), ('617','0.0218'), ('417','0.7168'), 
  ('46', '0.5616'), ('272','0.9778'), ('63', '0.2552'), 
  ('402','0.7655'), ('405','0.6929'), ('47', '0.0072'), 
  ('706','0.9649'), ('594','0.7670'), ('616','0.1003'), 
  ('276','0.2672'), ('363','0.2661'), ('986','0.8931'), 
  ('867','0.4050'), ('166','0.2507'), ('232','0.1598'), 
  ('161','0.7113'), ('701','0.0758'), ('624','0.8270'), 
  ('344','0.3761'), ('96', '0.4498'), ('991','0.4191'), 
  ('524','0.9876'), ('715','0.8921'), ('553','0.4418'), 
  ('640','0.8790'), ('847','0.4889'), ('126','0.3564'), 
  ('465','0.0895'), ('306','0.6487'), ('109','0.1151'), 
  ('998','0.0379'), ('913','0.2421'), ('482','0.5023'), 
  ('943','0.0452'), ('53','0.8169');

WITH ranked_images AS
(
  SELECT 
    image_id,
    ROW_NUMBER() OVER (ORDER BY score DESC) AS p_rnk,
    ROW_NUMBER() OVER (ORDER BY score ASC) AS n_rnk
  FROM unlabeled_image_predictions
)
SELECT 
	image_id, 1 AS weak_label 
FROM ranked_images 
WHERE (p_rnk % 3 = 1 AND p_rnk <= 29998)

UNION

SELECT 
	image_id, 0 AS weak_label 
FROM ranked_images 
WHERE (n_rnk % 3 = 1 AND n_rnk <= 29998);
