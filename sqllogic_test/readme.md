## how to run?

```
go build
./sqllogic_test -p path
```

Path is a test file or directory. You can use `-skip-error` flag to skip query errors when test.

## Where is the test cases?

+ checkout [https://github.com/pingcap/sqllogictest](https://github.com/pingcap/sqllogictest) to a place.
+ `cp -rf sqllogictest/test ./` and then run `./run-tests.sh`
