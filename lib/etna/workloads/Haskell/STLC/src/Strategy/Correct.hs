{-# LANGUAGE TemplateHaskell #-}

module Strategy.Correct where

import Etna.Lib
import Impl
import Spec
import Test.QuickCheck hiding (Result)

instance Arbitrary Typ where
  arbitrary = sized go
    where
      go 0 = return TBool
      go n =
        oneof
          [ go 0,
            TFun <$> go (n `div` 2) <*> go (n `div` 2)
          ]

instance Arbitrary Expr where
  arbitrary = do
    t <- (arbitrary :: Gen Typ)
    genExactExpr [] t

genExactExpr :: Ctx -> Typ -> Gen Expr
genExactExpr ctx t = sized $ \n -> go n ctx t
  where
    go 0 ctx t = oneof $ genOne ctx t : genVar ctx t
    go n ctx t =
      oneof
        ( [genOne ctx t]
            ++ [genAbs ctx t1 t2 | TFun t1 t2 <- [t]]
            ++ [genApp ctx t]
            ++ genVar ctx t
        )
      where
        genAbs ctx t1 t2 = Abs t1 <$> go (n - 1) (t1 : ctx) t2

        genApp ctx t = do
          t' <- arbitrary
          e1 <- go (n `div` 2) ctx (TFun t' t)
          e2 <- go (n `div` 2) ctx t'
          return (App e1 e2)

    genOne _ TBool = Bool <$> arbitrary
    genOne ctx (TFun t1 t2) = Abs t1 <$> genOne (t1 : ctx) t2

    genVar :: Ctx -> Typ -> [Gen Expr]
    genVar ctx t = [Var <$> elements vars | not (null vars)]
      where
        vars = filter (\i -> ctx !! i == t) [0 .. (length ctx - 1)]

$( mkStrategies
     [|qcRunArb qcDefaults Correct|]
     [ 'prop_SinglePreserve,
       'prop_MultiPreserve
     ]
 )