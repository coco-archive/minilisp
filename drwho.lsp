(DEFUN MAKE-DR(NUM PHRASE)
  (LAMBDA (MSG)
    (IF (EQ MSG 'NUM)
      NUM
      (IF (EQ MSG 'PHRASE)
        PHRASE
        'UNKNOWN_MSG))))


(DEFINE HARTNELL (MAKE-DR 1 'HMMN))
(DEFINE TROUGHTON (MAKE-DR 2 'I-DONT-LIKE-IT))
(DEFINE PERTWEE (MAKE-DR 3 'REVERSE-THE-POLARITY))
(DEFINE TOM-BAKER (MAKE-DR 4 'JELLY-BABY))
(DEFINE DAVISON (MAKE-DR 5 'NOT-TO-REVERSE-THE-POLARITY-OF-THE-NEUTRON-FLOW))
(DEFINE COLIN-BAKER (MAKE-DR 6 'AN-ALIEN-SPY))
(DEFINE MCCOY (MAKE-DR 7 'IM-READY))
(DEFINE MCGANN (MAKE-DR 8 'IM-READY))
(DEFINE ECCLESTON (MAKE-DR 9 'FANTASTIC))
(DEFINE TENNANT (MAKE-DR 10 'ALLONS-Y))
(DEFINE SMITH (MAKE-DR 11 'GERONIMO))
(DEFINE CAPALDI (MAKE-DR 12 'SHUTTITY-UP-UP-UP))

(DEFUN MAKE-DRWHO-UNIVERSE()
  (DEFINE DOCTORS
    (CONS HARTNELL (CONS TROUGHTON (CONS PERTWEE
      (CONS TOM-BAKER (CONS DAVISON (CONS COLIN-BAKER
      (CONS MCGANN (CONS ECCLESTON (CONS TENNANT
      (CONS SMITH (CONS CAPALDI '()))))))))))))
  (LAMBDA (MSG)
    (IF (EQ MSG 'CURRENT)
      (CAR DOCTORS)
      (IF (EQ MSG 'REGENERATE)
        ((LAMBDA  ()
          (SETQ DOCTORS (CDR DOCTORS))
          '())) 
        'UNKNOWN_MSG))))
