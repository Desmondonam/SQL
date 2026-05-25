-- ============================================================
--  SQL INTERVIEW PREP — 03: Sorting & Limiting  ✅ SOLUTIONS
-- ============================================================
USE stackoverflow_db;

-- Q1. Users sorted by reputation DESC.
SELECT * FROM users ORDER BY reputation DESC;

-- Q2. Top 5 highest-reputation users.
SELECT * FROM users ORDER BY reputation DESC LIMIT 5;

-- Q3. Questions sorted by view_count ASC.
SELECT * FROM questions ORDER BY view_count ASC;

-- Q4. 3 most recently asked questions.
SELECT * FROM questions ORDER BY created_at DESC LIMIT 3;

-- Q5. Questions sorted by answer_count DESC, then score DESC.
SELECT * FROM questions
ORDER BY answer_count DESC, score DESC;

-- Q6. Page 2 of questions (page size=5, 0-indexed), newest first.
SELECT * FROM questions
ORDER BY created_at DESC
LIMIT 5 OFFSET 5;
-- OFFSET = (page_number - 1) * page_size = (2-1)*5 = 5

-- Q7. Top 3 users by answer_count, tiebreak by username alpha.
SELECT * FROM users
ORDER BY answer_count DESC, username ASC
LIMIT 3;

-- Q8. Top 5 highest-scoring answers.
SELECT * FROM answers
ORDER BY score DESC
LIMIT 5;

-- Q9. Top 10 questions by view_count.
SELECT question_id, title, view_count, score
FROM questions
ORDER BY view_count DESC
LIMIT 10;

-- Q10. Bottom 5 questions by score (excluding 0), lowest first.
SELECT * FROM questions
WHERE score > 0
ORDER BY score ASC
LIMIT 5;

-- ── KEY TAKEAWAYS ──────────────────────────────────────────
-- • ORDER BY col DESC → highest first; ASC → lowest first.
-- • LIMIT n → returns at most n rows.
-- • LIMIT n OFFSET m → skip first m rows, then take n.
-- • Multiple ORDER BY columns: first column is primary sort,
--   subsequent columns break ties.
-- • Pagination formula: OFFSET = (page - 1) * page_size.
-- • Always pair LIMIT with ORDER BY for deterministic results.
-- ───────────────────────────────────────────────────────────
