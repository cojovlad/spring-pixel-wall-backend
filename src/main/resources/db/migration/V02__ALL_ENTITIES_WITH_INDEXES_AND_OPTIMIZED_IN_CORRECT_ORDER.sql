-- Step 1: Users
CREATE TABLE IF NOT EXISTS users (
                                     id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                                     uuid CHAR(36) UNIQUE NOT NULL,
                                     oauth_provider ENUM('GOOGLE','FACEBOOK','GITHUB','TWITTER') NOT NULL,
                                     oauth_id VARCHAR(128) NOT NULL,
                                     email VARCHAR(254) NOT NULL,
                                     display_name VARCHAR(64),
                                     avatar_hash CHAR(64),
                                     role TINYINT UNSIGNED DEFAULT 0,
                                     created_at TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
                                     updated_at TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
                                     last_active_at TIMESTAMP(3) NULL
) ENGINE=InnoDB ROW_FORMAT=COMPRESSED KEY_BLOCK_SIZE=8;

-- Step 2: Pixels & Pixel Metadata
CREATE TABLE IF NOT EXISTS pixels (
                                      x SMALLINT UNSIGNED NOT NULL,
                                      y SMALLINT UNSIGNED NOT NULL,
                                      status ENUM('FREE','PENDING','APPROVED') DEFAULT 'FREE',
                                      group_id INT UNSIGNED NULL,
                                      updated_at TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                                      PRIMARY KEY (x, y)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS pixel_metadata (
                                              x SMALLINT UNSIGNED NOT NULL,
                                              y SMALLINT UNSIGNED NOT NULL,
                                              group_id INT UNSIGNED NOT NULL,
                                              label_hash BINARY(32),
                                              link_hash BINARY(32),
                                              color_r TINYINT UNSIGNED,
                                              color_g TINYINT UNSIGNED,
                                              color_b TINYINT UNSIGNED,
                                              PRIMARY KEY (x, y)
) ENGINE=InnoDB ROW_FORMAT=COMPRESSED;

-- Step 3: Pixel Groups
CREATE TABLE IF NOT EXISTS pixel_groups (
                                            id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                                            uuid CHAR(36) UNIQUE NOT NULL,
                                            user_id INT UNSIGNED NOT NULL,
                                            status ENUM('PENDING','APPROVED','REJECTED','CANCELLED','EXPIRED') NOT NULL,
                                            shape_type ENUM('RECTANGLE','SQUARE','CUSTOM') NOT NULL,
                                            width SMALLINT UNSIGNED NOT NULL,
                                            height SMALLINT UNSIGNED NOT NULL,
                                            start_x SMALLINT UNSIGNED NOT NULL,
                                            start_y SMALLINT UNSIGNED NOT NULL,
                                            end_x SMALLINT UNSIGNED GENERATED ALWAYS AS (start_x + width - 1) STORED,
                                            end_y SMALLINT UNSIGNED GENERATED ALWAYS AS (start_y + height - 1) STORED,
                                            total_pixels MEDIUMINT UNSIGNED NOT NULL,
                                            label VARCHAR(192) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
                                            link VARCHAR(2048),
                                            link_safety ENUM('UNCHECKED','SAFE','SUSPICIOUS','MALICIOUS') DEFAULT 'UNCHECKED',
                                            link_check_at TIMESTAMP(3) NULL,
                                            admin_notified BOOLEAN DEFAULT FALSE,
                                            requires_attention BOOLEAN DEFAULT FALSE,
                                            expires_at TIMESTAMP(3) NULL,
                                            created_at TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
                                            updated_at TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
                                            CHECK (width BETWEEN 1 AND 1000),
                                            CHECK (height BETWEEN 1 AND 1000),
                                            CHECK (total_pixels <= 10000),
                                            CHECK (start_x + width <= 1000),
                                            CHECK (start_y + height <= 1000),
                                            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB ROW_FORMAT=COMPRESSED KEY_BLOCK_SIZE=8;

-- Step 4: PixelGroupPixels
CREATE TABLE IF NOT EXISTS pixel_group_pixels (
                                                  group_id INT UNSIGNED NOT NULL,
                                                  x SMALLINT UNSIGNED NOT NULL,
                                                  y SMALLINT UNSIGNED NOT NULL,
                                                  PRIMARY KEY (group_id, x, y),
                                                  UNIQUE KEY uk_pixel (x, y, group_id)
) ENGINE=InnoDB;

-- Step 5: Image Metadata
CREATE TABLE IF NOT EXISTS image_metadata (
                                              id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                                              group_id INT UNSIGNED UNIQUE NOT NULL,
                                              s3_key CHAR(40) NOT NULL,
                                              bucket ENUM('uploads','processed','archive') DEFAULT 'uploads',
                                              original_name VARCHAR(255),
                                              mime_type VARCHAR(100),
                                              original_width SMALLINT UNSIGNED,
                                              original_height SMALLINT UNSIGNED,
                                              suggested_width SMALLINT UNSIGNED,
                                              suggested_height SMALLINT UNSIGNED,
                                              file_size INT UNSIGNED,
                                              dominant_color INT UNSIGNED,
                                              checksum CHAR(64),
                                              processing_status ENUM('PENDING','PROCESSED','FAILED') DEFAULT 'PENDING',
                                              created_at TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
                                              FOREIGN KEY (group_id) REFERENCES pixel_groups(id) ON DELETE CASCADE
) ENGINE=InnoDB ROW_FORMAT=COMPRESSED;

-- Step 6: Payments
CREATE TABLE IF NOT EXISTS payments (
                                        id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                                        uuid CHAR(36) UNIQUE NOT NULL,
                                        group_id INT UNSIGNED UNIQUE NOT NULL,
                                        user_id INT UNSIGNED NOT NULL,
                                        amount DECIMAL(10,2) UNSIGNED NOT NULL,
                                        currency CHAR(3) NOT NULL DEFAULT 'RON',
                                        provider ENUM('STRIPE','PAYU','MANUAL','CASH') NOT NULL,
                                        provider_id VARCHAR(255) NOT NULL,
                                        status ENUM('PENDING','COMPLETED','FAILED','REFUNDED','PARTIAL_REFUND') NOT NULL,
                                        refund_amount DECIMAL(10,2) UNSIGNED DEFAULT 0.00,
                                        metadata JSON CHECK (JSON_VALID(metadata)),
                                        captured_at TIMESTAMP(3) NULL,
                                        refunded_at TIMESTAMP(3) NULL,
                                        created_at TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
                                        FOREIGN KEY (group_id) REFERENCES pixel_groups(id) ON DELETE RESTRICT,
                                        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Step 7: Audit Logs (NO PARTITIONING)
CREATE TABLE IF NOT EXISTS audit_logs (
                                          id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                                          group_id INT UNSIGNED NOT NULL,
                                          user_id INT UNSIGNED NULL,
                                          action ENUM('CREATED','UPDATED','APPROVED','REJECTED','FLAGGED','PAYMENT_RECEIVED','REFUNDED','EXPIRED','CANCELLED') NOT NULL,
                                          ip_address INT UNSIGNED NULL,
                                          user_agent_hash BINARY(32) NULL,
                                          details JSON CHECK (JSON_VALID(details)),
                                          created_at TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
                                          INDEX idx_group_timeline (group_id, created_at),
                                          INDEX idx_action_time (action, created_at),
                                          INDEX idx_user_actions (user_id, created_at)
) ENGINE=InnoDB ROW_FORMAT=COMPRESSED;

-- Step 8: User Sessions
CREATE TABLE IF NOT EXISTS user_sessions (
                                             id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                                             user_id INT UNSIGNED NOT NULL,
                                             session_token CHAR(64) NOT NULL UNIQUE,
                                             last_active TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                                             expires_at TIMESTAMP(6) NOT NULL,
                                             ip_address INT UNSIGNED,
                                             user_agent_hash BINARY(32),
                                             FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB ROW_FORMAT=COMPRESSED;

-- Step 9: Async Errors
CREATE TABLE IF NOT EXISTS async_errors (
                                            id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                                            table_name VARCHAR(64) NOT NULL,
                                            record_id INT UNSIGNED NOT NULL,
                                            error_code VARCHAR(32),
                                            error_details JSON CHECK (JSON_VALID(error_details)),
                                            created_at TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3)
) ENGINE=InnoDB ROW_FORMAT=COMPRESSED;

-- Step 10: Trigger for pixel group approval
DELIMITER $$

CREATE TRIGGER IF NOT EXISTS after_pixel_group_approved
    AFTER UPDATE ON pixel_groups
    FOR EACH ROW
BEGIN
    IF NEW.status = 'APPROVED' AND OLD.status <> 'APPROVED' THEN
        INSERT INTO pixel_metadata (x, y, group_id, label_hash, link_hash)
        SELECT pgp.x, pgp.y, NEW.id,
               UNHEX(SHA2(NEW.label, 256)),
               UNHEX(SHA2(NEW.link, 256))
        FROM pixel_group_pixels pgp;
    END IF;
END$$

DELIMITER ;
