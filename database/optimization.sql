-- ============================================================================ --
--                                                                              --
--                                 FILE HEADER                                  --
-- ---------------------------------------------------------------------------- --
--  File:       optimization.sql                                                --
--  Author:     dlesieur                                                        --
--  Email:      dlesieur@student.42.fr                                          --
--  Created:    2025/11/04 00:57:00                                             --
--  Updated:    2025/11/04 00:57:00                                             --
--                                                                              --
-- ============================================================================ --

-- Add indexes and optimize tables

CREATE INDEX idx_user_email ON `user`
(`email`);
CREATE INDEX idx_carpool_departure ON `
carpool`
(`departure_date`, `departure_place`);
CREATE INDEX idx_review_rating ON `
review`
(`rating`);

-- Foreign key helper indexes
CREATE INDEX idx_owns_user ON `
owns`
(`user_id`);
CREATE INDEX idx_owns_role ON `
owns`
(`role_id`);
CREATE INDEX idx_car_brand ON `
car`
(`brand_id`);
CREATE INDEX idx_manages_user ON `
manages`
(`user_id`);
CREATE INDEX idx_manages_car ON `
manages`
(`car_id`);
CREATE INDEX idx_uses_carpool ON `
uses`
(`carpool_id`);
CREATE INDEX idx_uses_car ON `
uses`
(`car_id`);
CREATE INDEX idx_participates_user ON `
participates`
(`user_id`);
CREATE INDEX idx_participates_carpool ON `
participates`
(`carpool_id`);
CREATE INDEX idx_submits_user ON `
submits`
(`user_id`);
CREATE INDEX idx_submits_review ON `
submits`
(`review_id`);

-- Example: Enable query cache (if supported)
-- The following MySQL-specific server variables are not valid in SQL Server and cause syntax errors.
-- If you are using MySQL, set these in the server configuration or via a MySQL client; if using SQL Server, remove or replace with appropriate server configuration.
-- SET GLOBAL query_cache_size = 1048576;
-- SET GLOBAL query_cache_type = 1;