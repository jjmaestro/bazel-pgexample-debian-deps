# Example: building PostgreSQL with Bazel

Build [PostgreSQL] with Bazel using [`rules_foreign_cc`] [`meson` rule].

Also, trying to use Debian packages for the external dependencies needed when
compiling additional [PostgreSQL features] (e.g. `-Dssl=openssl`).

[PostgreSQL]: https://www.postgresql.org
[`rules_foreign_cc`]: https://github.com/bazel-contrib/rules_foreign_cc
[`meson` rule]: https://bazel-contrib.github.io/rules_foreign_cc/main/flatten.html#meson
[PostgreSQL features]: https://www.postgresql.org/docs/current/install-meson.html#MESON-OPTIONS-FEATURES
