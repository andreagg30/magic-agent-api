import { pool } from "../database/db-connection.js";

const getByCategoryCode = async (categoryCode: string) => {
  const result = await pool.query(
    "SELECT * FROM get_catalog_items($1::text)",
    [categoryCode],
  );

  return result.rows;
};

export default { getByCategoryCode };
