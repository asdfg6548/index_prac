

CREATE TABLE product_index (
    id INT AUTO_INCREMENT PRIMARY KEY,
    prod_name VARCHAR(255),
    category VARCHAR(100),
    price DECIMAL(10, 2)
);

DELIMITER $$

CREATE PROCEDURE generate_dummy_products()
BEGIN
    DECLARE counter INT DEFAULT 0;

    WHILE counter < 50000 DO
        INSERT INTO product_index (prod_name, category, price)
        VALUES (
            CONCAT('Product ', counter + 1),
            ELT(FLOOR(1 + (RAND() * 5)), 'Electronics', 'Clothing', 'Books', 'Furniture', 'Toys'),
            ROUND(10 + (RAND() * 990), 2)
        );
        SET counter = counter + 1;
    END WHILE;
END$$

DELIMITER ;

CALL generate_dummy_products();


EXPLAIN SELECT *
FROM product_index
WHERE prod_name = 'Product 25000'
-- AND category = 'electronics'
;

ALTER TABLE product_index
  ADD INDEX idx_prod_name (prod_name)
, ADD INDEX idx_category (category)
, ADD INDEX idx_price (price);
;

ALTER TABLE product_index
  DROP INDEX idx_prod_name
;

EXPLAIN SELECT * FROM product_index WHERE prod_name = 'example';
EXPLAIN SELECT * FROM product_index WHERE category = 'electronics';
EXPLAIN SELECT * FROM product_index WHERE price = 500;

-- 범위 연산에는 인덱스 '보장' 불가 -> 우회적으로 하는게 좋음
EXPLAIN SELECT * FROM product_index WHERE price <= 500;
EXPLAIN SELECT * FROM product_index WHERE price <= 100;


ALTER TABLE product_index
ADD INDEX idx_category_prodname (category, prod_name),
ADD INDEX idx_category_price (category, price),
ADD INDEX idx_category_price_prodname (category, price, prod_name);

show index from product_index;

-- 불필요한 인덱스 드랍하기
ALTER TABLE product_index
DROP INDEX idx_category,
DROP INDEX idx_category_price;

EXPLAIN SELECT * FROM product_index WHERE prod_name = 'example' AND category = 'electronics';
EXPLAIN SELECT * FROM product_index WHERE category = 'electronics' AND prod_name = 'example';

