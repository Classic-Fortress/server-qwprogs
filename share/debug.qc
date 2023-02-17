#ifdef SSQC

#define IS_CSQC 0
#define IS_SSQC 1

// printf that works in any context
#define printf(...) bprint(PRINT_HIGH, sprintf(__VA_ARGS__))
#define printd(...) dprint(sprintf(__VA_ARGS__))

#elif defined(CSQC)

#define IS_CSQC 1
#define IS_SSQC 0

#define printf(...) print(sprintf(__VA_ARGS__))

#endif

inline string qc_prefix() {
#ifdef SSQC
    return "SSQC";
#else
    return "CSQC";
#endif
}

#define MSEC 0.001
#define SEC  1

#define errors(fmt, ...) error(sprintf("%s:%d Error> " fmt, __FILE__, __LINE__))
#define errorf(fmt, ...) error(sprintf("%s:%d Error> " fmt, __FILE__, __LINE__, __VA_ARGS__))

#define _ASSERT_OP(_op, _invop, _fmt, _val1, _v2) \
    if (!((_val1) _op (_v2))) \
        errorf("Expected: %s " #_op " %s, but: " #_fmt " " #_invop " " #_fmt "\n", #_val1, #_v2, _val1, _v2)

#define __ASSERT_OP(_op, _invop, _fmt, _v1, _v2, __v1, __v2) \
    if (!((__v1) _op (__v2))) \
        errorf("Expected: %s " #_op " %s, but: " #_fmt " " #_invop " " #_fmt "\n", #_v1, #_v2, __v1, __v2)

#define ASSERTF_EQ(_v1, _v2) _ASSERT_OP(==, !=, %0.2f, _v1, _v2)
#define ASSERTF_NE(_v1, _v2) _ASSERT_OP(!=, ==, %0.2f, _v1, _v2)
#define ASSERTF_GT(_v1, _v2) _ASSERT_OP( >, <=, %0.2f, _v1, _v2)
#define ASSERTF_GE(_v1, _v2) _ASSERT_OP(>=,  <, %0.2f, _v1, _v2)
#define ASSERTF_LT(_v1, _v2) _ASSERT_OP( <, >=, %0.2f, _v1, _v2)
#define ASSERTF_LE(_v1, _v2) _ASSERT_OP(<=,  <, %0.2f, _v1, _v2)


// Work around general weird behaviors with __int
float __as_float(float v) { return v; }

#define ASSERTD_EQ(_v1, _v2) __ASSERT_OP(==, !=, %d, _v1, _v2, __as_float(_v1), __as_float(_v2))
#define ASSERTD_NE(_v1, _v2) __ASSERT_OP(!=, ==, %d, _v1, _v2, __as_float(_v1), __as_float(_v2))
#define ASSERTD_GT(_v1, _v2) __ASSERT_OP( >, <=, %d, _v1, _v2, __as_float(_v1), __as_float(_v2))
#define ASSERTD_GE(_v1, _v2) __ASSERT_OP(>=,  <, %d, _v1, _v2, __as_float(_v1), __as_float(_v2))
#define ASSERTD_LT(_v1, _v2) __ASSERT_OP( <, >=, %d, _v1, _v2, __as_float(_v1), __as_float(_v2))
#define ASSERTD_LE(_v1, _v2) __ASSERT_OP(<=,  <, %d, _v1, _v2, __as_float(_v1), __as_float(_v2))

#define ASSERTS_EQ(_v1, _v2) _ASSERT_OP(==, !=,    %s, _v1, _v2)
#define ASSERTS_NE(_v1, _v2) _ASSERT_OP(!=, ==,    %s, _v1, _v2)

#define ASSERTF_TRUE(_v1)     ASSERTF_EQ(_v1, TRUE)
#define ASSERTF_FALSE(_v1)    ASSERTF_EQ(_v1, FALSE)


#define __CONCAT(_a, _b) _a ## _b
#define _PRINT_ONCE(_n, ...) \
    do { static float _n; if (!_n) { _n = TRUE; printf(__VA_ARGS__); } } while (0)
#define _PRINT_EVERY(_n, _p, ...) \
    do { static float _n; if (time > _n + _p) { _n = time + _p; printf(__VA_ARGS__); } } while (0)

#define PRINT_ONCE(...) _PRINT_ONCE(__CONCAT(__once, __LINE__), __VA_ARGS__)
#define PRINT_EVERY(_p, ...) _PRINT_EVERY(__CONCAT(__every, __LINE_), _p, __VA_ARGS__)

#define EPS 0.001
#define FEQ(_v1, _v2) (fabs(_v1 - _v2) < EPS)
#define FNEQ(_v1, _v2) (fabs(_v1 - _v2) >= EPS)
