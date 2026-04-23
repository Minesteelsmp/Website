-- ============================================================
-- CubiqHost - Complete MySQL Schema (v2, cleaned)
-- Run on a fresh MySQL/MariaDB database:
--   mysql -u root -p < scripts/mysql_schema.sql
--
-- Notes:
--  - `plans` table holds SERVER plans only. World plans live in `world_plans`.
--  - `backups`, `ports`, `plan_type`, `nest_id` columns removed from queries.
--    Defaults are now hardcoded in application code (1 backup, 1 port, nest 1).
-- ============================================================

CREATE DATABASE IF NOT EXISTS cubiqhost CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE cubiqhost;

-- -- Users -----------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
  id                   INT AUTO_INCREMENT PRIMARY KEY,
  email                VARCHAR(255) UNIQUE NOT NULL,
  password_hash        VARCHAR(255) NOT NULL,
  full_name            VARCHAR(255),
  is_admin             BOOLEAN DEFAULT FALSE,

  pterodactyl_user_id  INT NULL,

  reset_token          VARCHAR(255) NULL,
  reset_token_expires  TIMESTAMP NULL,

  created_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- -- Plans (server plans only) ---------------------------------
CREATE TABLE IF NOT EXISTS plans (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  name         VARCHAR(100) NOT NULL,
  slug         VARCHAR(100) UNIQUE NOT NULL,
  price        INT NOT NULL,
  cpu_percent  INT NOT NULL,
  ram_mb       INT NOT NULL,
  storage_mb   INT NOT NULL,
  is_active    BOOLEAN DEFAULT TRUE,
  sort_order   INT DEFAULT 0,
  created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- -- Software options (Pterodactyl eggs) -----------------------
CREATE TABLE IF NOT EXISTS software_options (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(100) NOT NULL,
  slug        VARCHAR(100) UNIQUE NOT NULL,
  egg_id      INT NOT NULL,
  is_active   BOOLEAN DEFAULT TRUE,
  sort_order  INT DEFAULT 0,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- -- Servers ---------------------------------------------------
CREATE TABLE IF NOT EXISTS servers (
  id                  INT AUTO_INCREMENT PRIMARY KEY,
  user_id             INT NOT NULL,
  plan_id             INT NOT NULL,
  server_name         VARCHAR(255) NOT NULL,
  software_id         INT NULL,
  pterodactyl_id      INT NULL,
  pterodactyl_uuid    VARCHAR(255) NULL,
  pterodactyl_identifier VARCHAR(16) NULL,
  status              ENUM('active','suspended','deleted') DEFAULT 'active',
  expires_at          TIMESTAMP NOT NULL,
  suspended_at        TIMESTAMP NULL,
  created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  FOREIGN KEY (user_id)     REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (plan_id)     REFERENCES plans(id),
  FOREIGN KEY (software_id) REFERENCES software_options(id)
) ENGINE=InnoDB;

-- -- Server subusers (sharing) ---------------------------------
CREATE TABLE IF NOT EXISTS server_subusers (
  id                  INT AUTO_INCREMENT PRIMARY KEY,
  server_id           INT NOT NULL,
  owner_user_id       INT NOT NULL,
  shared_user_id      INT NOT NULL,
  permissions         TEXT NULL,
  pterodactyl_uuid    VARCHAR(255) NULL,
  created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  UNIQUE KEY unique_share (server_id, shared_user_id),
  FOREIGN KEY (server_id)      REFERENCES servers(id) ON DELETE CASCADE,
  FOREIGN KEY (owner_user_id)  REFERENCES users(id)   ON DELETE CASCADE,
  FOREIGN KEY (shared_user_id) REFERENCES users(id)   ON DELETE CASCADE
) ENGINE=InnoDB;

-- -- Orders ----------------------------------------------------
CREATE TABLE IF NOT EXISTS orders (
  id                  INT AUTO_INCREMENT PRIMARY KEY,
  user_id             INT NOT NULL,
  plan_id             INT NOT NULL,
  server_name         VARCHAR(255) NOT NULL,
  software_id         INT NULL,
  status              ENUM('pending','approved','rejected','cancelled') DEFAULT 'pending',
  payment_sender_name VARCHAR(255) NULL,
  amount              INT NOT NULL,
  order_type          ENUM('new','renewal','upgrade') NOT NULL,
  related_server_id   INT NULL,
  created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  FOREIGN KEY (user_id)     REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (plan_id)     REFERENCES plans(id),
  FOREIGN KEY (software_id) REFERENCES software_options(id)
) ENGINE=InnoDB;

-- -- Invoices --------------------------------------------------
CREATE TABLE IF NOT EXISTS invoices (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  user_id     INT NOT NULL,
  order_id    INT NOT NULL,
  server_id   INT NULL,
  amount      INT NOT NULL,
  type        ENUM('new','renewal','upgrade','world') NOT NULL,
  status      ENUM('pending','paid') DEFAULT 'paid',
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  FOREIGN KEY (user_id)   REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (order_id)  REFERENCES orders(id),
  FOREIGN KEY (server_id) REFERENCES servers(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- -- Site settings (key-value) --------------------------------
CREATE TABLE IF NOT EXISTS site_settings (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  setting_key   VARCHAR(100) UNIQUE NOT NULL,
  setting_value TEXT NOT NULL,
  updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- -- World plans ----------------------------------------------
CREATE TABLE IF NOT EXISTS world_plans (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  name         VARCHAR(50) NOT NULL,
  slug         VARCHAR(50) UNIQUE NOT NULL,
  description  TEXT,
  price        DECIMAL(10,2) NOT NULL,
  cpu_percent  INT NOT NULL DEFAULT 100,
  ram_mb       INT NOT NULL DEFAULT 2048,
  storage_mb   INT NOT NULL DEFAULT 5120,
  is_active    BOOLEAN DEFAULT TRUE,
  sort_order   INT DEFAULT 0,
  created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- -- World purchases ------------------------------------------
CREATE TABLE IF NOT EXISTS world_purchases (
  id                    INT AUTO_INCREMENT PRIMARY KEY,
  user_id               INT NOT NULL,
  world_plan_id         INT NOT NULL,
  payment_sender_name   VARCHAR(255) NULL,
  status                ENUM('pending','active','completed','cancelled') DEFAULT 'pending',
  pterodactyl_server_id INT NULL,
  admin_notes           TEXT NULL,
  created_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  expires_at            TIMESTAMP NULL,

  FOREIGN KEY (user_id)       REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (world_plan_id) REFERENCES world_plans(id)
) ENGINE=InnoDB;

-- ============================================================
-- Seed data
-- ============================================================

-- Admin user (password: wwadaar123 -- CHANGE IN PRODUCTION)
INSERT INTO users (email, password_hash, full_name, is_admin) VALUES
('support.cubiqhost@gmail.com',
 '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/X4JmVj/9isjCjNHje',
 'CubiqHost Admin', TRUE)
ON DUPLICATE KEY UPDATE email = email;

-- Server plans (price in INR)
INSERT INTO plans (name, slug, price, cpu_percent, ram_mb, storage_mb, sort_order) VALUES
('Dirt',      'dirt',      39,  50,  512,   2048,  1),
('Grass',     'grass',     69,  75,  1024,  3072,  2),
('Stone',     'stone',     129, 100, 2048,  5120,  3),
('Iron',      'iron',      189, 125, 3072,  7168,  4),
('Gold',      'gold',      249, 150, 4096,  10240, 5),
('Diamond',   'diamond',   309, 175, 5120,  12288, 6),
('Emerald',   'emerald',   369, 200, 6144,  15360, 7),
('Netherite', 'netherite', 399, 250, 8192,  20480, 8)
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- World plans
INSERT INTO world_plans (name, slug, description, price, cpu_percent, ram_mb, storage_mb, sort_order) VALUES
('Survival', 'survival', 'A classic survival world with balanced gameplay.',        49.00, 75,  1024, 3072, 1),
('OneBlock', 'oneblock', 'Build your world one block at a time.',                   29.00, 50,  512,  2048, 2),
('KitPvP',   'kitpvp',   'Fast-paced PvP arena with pre-built kits.',               79.00, 100, 2048, 5120, 3),
('Bedwars',  'bedwars',  'Protect your bed and destroy others in team battles.',    89.00, 125, 2048, 5120, 4)
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- Software (Pterodactyl egg IDs)
INSERT INTO software_options (name, slug, egg_id, sort_order) VALUES
('Paper',          'paper',           1,  1),
('Vanilla Java',   'vanilla-java',    2,  2),
('Forge',          'forge',           3,  3),
('Fabric',         'fabric',          4,  4),
('Sponge',         'sponge',          5,  5),
('Bungeecord',     'bungeecord',      15, 6),
('Waterfall',      'waterfall',       16, 7),
('Velocity',       'velocity',        17, 8),
('Vanilla Bedrock','vanilla-bedrock', 18, 9),
('PocketMineMP',   'pocketmine',      19, 10),
('Nukkit',         'nukkit',          20, 11)
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- Site settings
INSERT INTO site_settings (setting_key, setting_value) VALUES
('site_name',        'CubiqHost'),
('logo_url',         ''),
('upi_id',           'anshumanisman@oksbi'),
('upi_name',         'Vanita Vijay Salunkhe'),
('upi_qr_url',       ''),
('discord_invite',   'https://discord.gg/AV6bnrxrW'),
('discord_url',      'https://discord.gg/AV6bnrxrW'),
('instagram_url',    ''),
('youtube_url',      ''),
('support_email',    'support.cubiqhost@gmail.com'),
('site_status',      'online'),
('status_message',   'All systems operational'),
('maintenance_mode', 'off'),
('panel_url',        'https://panel.cubiqhost.in'),
('hero_title',       'CubiqHost - Where Your Minecraft Server Comes Alive Instantly'),
('hero_subtitle',    'Affordable, fast & reliable Minecraft hosting built for smooth gameplay.')
ON DUPLICATE KEY UPDATE setting_key = setting_key;
