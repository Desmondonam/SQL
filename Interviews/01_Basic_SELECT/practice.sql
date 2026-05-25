-- ============================================================
--  SQL INTERVIEW PREP — 01: Basic SELECT Queries
--  Level     : Beginner
--  Dataset   : Netflix-inspired Shows & Movies catalog
--  Source    : Inspired by Kaggle "Netflix Movies and TV Shows"
--              https://www.kaggle.com/datasets/shivamb/netflix-shows
-- ============================================================

-- ── SETUP: Run this block first to create and populate tables ──

CREATE DATABASE IF NOT EXISTS netflix_db;
USE netflix_db;

DROP TABLE IF EXISTS netflix_titles;
CREATE TABLE netflix_titles (
    show_id      VARCHAR(10)  PRIMARY KEY,
    type         VARCHAR(10)  NOT NULL,          -- 'Movie' or 'TV Show'
    title        VARCHAR(200) NOT NULL,
    director     VARCHAR(200),
    country      VARCHAR(150),
    date_added   DATE,
    release_year SMALLINT,
    rating       VARCHAR(10),
    duration     VARCHAR(20),
    listed_in    VARCHAR(200),
    description  TEXT
);

INSERT INTO netflix_titles VALUES
 ('s1',  'Movie',   'The Irishman',         'Martin Scorsese', 'United States', '2019-11-27', 2019, 'R',     '209 min', 'Dramas, International Movies',            'An aging hitman recalls his time with the mob.'),
 ('s2',  'TV Show', 'Stranger Things',      NULL,              'United States', '2016-07-15', 2016, 'TV-14', '4 Seasons','Kids TV, Sci-Fi & Fantasy TV Shows',     'A group of kids uncover a government conspiracy.'),
 ('s3',  'Movie',   'Parasite',             'Bong Joon-ho',    'South Korea',   '2020-02-07', 2019, 'R',     '132 min', 'Dramas, International Movies, Thrillers', 'A poor family schemes to become employed by a wealthy family.'),
 ('s4',  'TV Show', 'Money Heist',          'Álex Pina',       'Spain',         '2017-12-20', 2017, 'TV-MA', '5 Seasons','Crime TV Shows, International TV Shows','A criminal mastermind plans the biggest heist ever.'),
 ('s5',  'Movie',   'Bird Box',             'Susanne Bier',    'United States', '2018-12-21', 2018, 'R',     '124 min', 'Dramas, Thrillers',                       'A woman must guide her children to safety blindfolded.'),
 ('s6',  'TV Show', 'Dark',                 'Baran bo Odar',   'Germany',       '2017-12-01', 2017, 'TV-MA', '3 Seasons','International TV Shows, Sci-Fi & Fantasy','A family saga with a supernatural twist.'),
 ('s7',  'Movie',   'The Social Network',   'David Fincher',   'United States', '2021-03-15', 2010, 'PG-13', '120 min', 'Dramas',                                  'The founding of Facebook leads to multiple lawsuits.'),
 ('s8',  'TV Show', 'Narcos',               NULL,              'United States', '2015-08-28', 2015, 'TV-MA', '3 Seasons','Crime TV Shows, Dramas',                 'The rise of cocaine cartels in Colombia.'),
 ('s9',  'Movie',   'Extraction',           'Sam Hargrave',    'United States', '2020-04-24', 2020, 'R',     '116 min', 'Action & Adventure, International Movies','A mercenary embarks on a deadly mission.'),
 ('s10', 'TV Show', 'The Crown',            NULL,              'United Kingdom','2016-11-04', 2016, 'TV-MA', '5 Seasons','Dramas, International TV Shows',          'The reign of Queen Elizabeth II.'),
 ('s11', 'Movie',   'Okja',                 'Bong Joon-ho',    'South Korea',   '2017-06-28', 2017, 'TV-MA', '120 min', 'Action & Adventure, Dramas',              'A girl risks everything to save her best friend.'),
 ('s12', 'TV Show', 'Squid Game',           'Hwang Dong-hyuk', 'South Korea',   '2021-09-17', 2021, 'TV-MA', '1 Season', 'International TV Shows, Thrillers',      'Desperate players compete in deadly childrens games.'),
 ('s13', 'Movie',   'The Old Guard',        'Gina Prince-Bythewood','United States','2020-07-10',2020,'R',  '118 min', 'Action & Adventure, Dramas',              'Immortal mercenaries fight to keep their secret.'),
 ('s14', 'TV Show', 'Breaking Bad',         NULL,              'United States', '2022-01-12', 2008, 'TV-MA', '5 Seasons','Crime TV Shows, Dramas',                 'A chemistry teacher turned drug manufacturer.'),
 ('s15', 'Movie',   'The Platform',         'Galder Gaztelu-Urrutia','Spain',  '2020-03-20', 2019, 'TV-MA', '94 min',  'Horror Movies, International Movies, Thrillers','A prison with vertical levels and one platform of food.'),
 ('s16', 'TV Show', 'Lupin',                'Louis Leterrier',  'France',        '2021-01-08', 2021, 'TV-MA', '3 Seasons','Crime TV Shows, International TV Shows','A man inspired by master thief Arsène Lupin.'),
 ('s17', 'Movie',   'Roma',                 'Alfonso Cuarón',   'Mexico',        '2018-11-21', 2018, 'R',     '135 min', 'Dramas, International Movies',            'A year in the life of a middle-class family in Mexico City.'),
 ('s18', 'TV Show', 'The Witcher',          'Lauren Schmidt Hissrich','United States','2019-12-20',2019,'TV-MA','3 Seasons','Action & Adventure, Fantasy TV Shows','A mutated monster hunter for hire.'),
 ('s19', 'Movie',   'Mulan',                'Niki Caro',        'United States', '2020-09-04', 2020, 'PG-13', '115 min', 'Action & Adventure, Children & Family',  'A young Chinese woman joins the Imperial Army.'),
 ('s20', 'TV Show', 'Emily in Paris',       'Darren Star',      'United States', '2020-10-02', 2020, 'TV-MA', '4 Seasons','Romantic TV Shows, International TV Shows','A Chicago marketing exec moves to Paris.');

-- ─────────────────────────────────────────────────────────────
--  TASKS (solve each question below without looking at solutions)
-- ─────────────────────────────────────────────────────────────

-- Q1. [EASY] Retrieve ALL columns for every title in the catalog.

SELECT * FROM netflix_titles;

SHOW TABLES;

-- Q2. [EASY] Show only the title, type, and release_year columns for all records.



-- Q3. [EASY] How many titles are in the catalog? (Return a single number.)



-- Q4. [EASY] Show all DISTINCT content types available (Movie vs TV Show).



-- Q5. [EASY] Show all titles along with a new computed column called "age"
--     that is (2024 - release_year). Alias the original column as content_title.



-- Q6. [EASY] List all titles with their rating. Show the column
--     rating as "content_rating" in the output.



-- Q7. [EASY] Retrieve the title, country, and duration of all Movies.



-- Q8. [MEDIUM] Show the title, type, and release_year of the 5 most recently
--     released titles (no ORDER BY yet — just select the columns for now,
--     you will sort in a later module).



-- Q9. [MEDIUM] Select all columns, plus add a column called "decade" computed
--     as: FLOOR(release_year / 10) * 10  (e.g., 2019 → 2010).



-- Q10. [MEDIUM] Display each title together with a label column called
--      "era" using a CASE expression:
--        - Before 2000  → 'Classic'
--        - 2000–2009    → '2000s'
--        - 2010–2019    → '2010s'
--        - 2020 onward  → 'Recent'
