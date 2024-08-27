use index_prac;


CREATE TABLE product_bool (
    product_id INT auto_increment PRIMARY KEY,
    is_electronics BOOLEAN,
    is_furniture BOOLEAN,
    is_seasonal BOOLEAN,
    category_bitmap INT GENERATED ALWAYS AS (
        (is_electronics << 2) | (is_furniture << 1) | is_seasonal
    ) STORED, -- 생성된 컬럼으로 비트맵을 표현
    INDEX idx_category_bitmap (category_bitmap) -- 비트맵 인덱스
);

DELIMITER $$

CREATE PROCEDURE generate_product_bool_data(IN num_records INT)
BEGIN
    DECLARE counter INT DEFAULT 1;

    WHILE counter <= num_records DO
        INSERT INTO product_bool (is_electronics, is_furniture, is_seasonal)
        VALUES (
            (RAND() < 0.5), -- 랜덤하게 TRUE 또는 FALSE를 생성
            (RAND() < 0.5),
            (RAND() < 0.5)
        );
        SET counter = counter + 1;
    END WHILE;
END$$

DELIMITER ;

CALL generate_product_bool_data(10000);

EXPLAIN SELECT * FROM product_bool
WHERE is_electronics = TRUE
AND is_seasonal = TRUE;

-- Bitmap 연산 (컬럼 비교연산만 절약, 인덱스 사용 불가)
EXPLAIN SELECT *
FROM product_bool
WHERE (category_bitmap & 0b101) = 0b101;

EXPLAIN SELECT *
FROM product_bool
WHERE (category_bitmap & 5) = 5;

-- 둘 다 성능이 좋은 편
-- In 연산 (인덱스 사용 가능하지만 filtering 비교연산)
EXPLAIN SELECT * FROM product_bool
WHERE category_bitmap in (5, 7);

-- Index 키 조회 (인덱스 태움, 필요한 행만 읽어들임)
EXPLAIN SELECT * FROM product_bool
WHERE category_bitmap = 7
UNION ALL
SELECT * FROM product_bool
WHERE category_bitmap = 5;