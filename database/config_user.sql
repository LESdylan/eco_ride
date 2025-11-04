-- ============================================================================ --
--                                                                              --
--                                 FILE HEADER                                  --
-- ---------------------------------------------------------------------------- --
--  File:       config_user.sql                                                 --
--  Author:     dlesieur                                                        --
--  Email:      dlesieur@student.42.fr                                          --
--  Created:    2025/11/04 00:55:43                                             --
--  Updated:    2025/11/04 00:55:43                                             --
--                                                                              --
-- ============================================================================ --


CREATE USER IF NOT EXISTS 'admin'@'%' IDENTIFIED BY 'admin_password';
GRANT ALL PRIVILEGES ON codrive.* TO 'admin'@'%';

CREATE USER IF NOT EXISTS 'readonly'@'%' IDENTIFIED BY 'readonly_password';
GRANT SELECT ON codrive.* TO 'readonly'@'%';

FLUSH PRIVILEGES;