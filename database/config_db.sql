-- ============================================================================ --
--                                                                              --
--                                 FILE HEADER                                  --
-- ---------------------------------------------------------------------------- --
--  File:       config_db.sql                                                   --
--  Author:     dlesieur                                                        --
--  Email:      dlesieur@student.42.fr                                          --
--  Created:    2025/11/04 00:58:44                                             --
--  Updated:    2025/11/04 00:58:44                                             --
--                                                                              --
-- ============================================================================ --

-- Set database-level options

ALTER DATABASE codrive CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Example: Set SQL mode
SET GLOBAL sql_mode = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';