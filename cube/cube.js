// SQL API users and the access_policy groups they belong to. Each Metabase
// connection logs in as one of these users; credentials come from env vars.
const sqlUsers = [
  {
    user: process.env.CUBEJS_SQL_USER,
    password: process.env.CUBEJS_SQL_PASSWORD,
    groups: [],
  },
  {
    user: process.env.CUBEJS_PEOPLE_SQL_USER,
    password: process.env.CUBEJS_PEOPLE_SQL_PASSWORD,
    groups: ['people'],
  },
].filter(({ user, password }) => user && password);

module.exports = {
  checkSqlAuth: async (req, userName, password) => {
    const sqlUser = sqlUsers.find(({ user }) => user === userName);
    if (!sqlUser || sqlUser.password !== password) {
      throw new Error('Access denied');
    }
    return {
      password: sqlUser.password,
      securityContext: { groups: sqlUser.groups },
    };
  },

  // Feeds `group:` in access_policy (e.g. cubes/new_user_activation.yml).
  contextToGroups: ({ securityContext }) => securityContext.groups || [],
};
