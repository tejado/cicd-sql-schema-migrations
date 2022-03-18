CREATE TABLE `payments` (
  `customerNumber` int NOT NULL,
  `checkNumber` varchar(50) NOT NULL,
  `paymentDate` date NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  PRIMARY KEY (`customerNumber`,`checkNumber`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
