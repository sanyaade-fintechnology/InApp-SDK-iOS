-- phpMyAdmin SQL Dump
-- version 4.2.10
-- http://www.phpmyadmin.net
--
-- Host: localhost:8889
-- Generation Time: Nov 14, 2014 at 02:58 PM
-- Server version: 5.5.38
-- PHP Version: 5.6.2

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

--
-- Database: `inAppPayment`
--

-- --------------------------------------------------------

--
-- Table structure for table `PITABLE`
--

CREATE TABLE `PITABLE` (
  `piToken` varchar(255) NOT NULL,
  `userToken` varchar(255) NOT NULL,
  `piDetails` varchar(255) NOT NULL,
  `identifier` varchar(255) NOT NULL,
  `piIndex` int(11) NOT NULL,
  `piEnabled` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `PITABLE`
--

INSERT INTO `PITABLE` (`piToken`, `userToken`, `piDetails`, `identifier`, `piIndex`, `piEnabled`) VALUES
('075188b8616564a1c5cb53fede15cb', '5d1e7e08abfc13807d1a1d42c22ad8', '{"cvv":"775","expiryMonth":"41","expiryYear":"41","pan":"1254589907559856","type":"CC"}', '623aa1a933469ff56cd55d5bbd4a71b9', 1, 0),
('08fb38990ce665ff9863a4d8d1b17e', '0ba56b09d0fac85d23bce3ffa271e4', '{"ccv":"555","expiryMonth":"25","expiryYear":"55","pan":"254588","type":"CC"}', 'c4693c20e8dccfcc2e7da5feb9704b83', 15, 1),
('12170f59eae00aa6c972821da8315a', '0ba56b09d0fac85d23bce3ffa271e4', '{"authToken":"Auhskkdmms","type":"PAYPAL"}', '676d1b977d38504a491c08eee22d2c64', 11, 1),
('24650827867b89d55837bf75f3c3f0', '0ba56b09d0fac85d23bce3ffa271e4', '{"cvv":"sadf","expiryMonth":"12","expiryYear":"12","pan":"123123","type":"CC"}', 'f1533864395ca8f60eba795ed32b1e9f', 3, 1),
('2b35bc528ca0dcff01b43122a1ccef', '5d1e7e08abfc13807d1a1d42c22ad8', '{"cvv":"552525","expiryMonth":"288","expiryYear":"288","pan":"22578666667575754545","type":"CC"}', 'ae928b7bc3015700f0d08f76f9ed8493', 0, 0),
('34ee55d2aa62fc6d48816650ac2146', '0ba56b09d0fac85d23bce3ffa271e4', '{"bic":"Hdhns","iban":"Sujshs","type":"SEPA"}', '73329510b13a07fc3965f3c7b053cdf2', 14, 1),
('48eb167fd1d452ebe3b6a77d0673e5', '0ba56b09d0fac85d23bce3ffa271e4', '{"ccv":"1232","expiryMonth":"12","expiryYear":"12","pan":"abcdef","type":"CC"}', '1ecbc65511394d82eb381e3d5817adf0', 4, 1),
('567596b8bb3a11e9b7238f5efccd68', '0ba56b09d0fac85d23bce3ffa271e4', '{"cvv":"5485","expiryMonth":"51","expiryYear":"51","pan":"218848564646","type":"CC"}', 'e1ed025147380089b655fd5839dd804f', 7, 1),
('68b0bf406dbe431dd8a2bbd948e39e', '0ba56b09d0fac85d23bce3ffa271e4', '{"ccv":"2558","expiryMonth":"65","expiryYear":"28","pan":"85463464","type":"CC"}', '94b525f31bd7c5a2716bdb77681478ed', 16, 1),
('73574af17a38b8f87656d4e9231526', '5d1e7e08abfc13807d1a1d42c22ad8', '{"authToken":"shshsheheu82hdjw","type":"PAYPAL"}', '0870c544b93d43778e32322e8655627f', 2, 0),
('8f509c5d0cb5d8f4ac047620c6aaca', '0ba56b09d0fac85d23bce3ffa271e4', '{"cvv":"5546","expiryMonth":"25","expiryYear":"25","pan":"25545","type":"CC"}', '3450e4c63853a92695eba92c6cd21382', 8, 1),
('9425d99823efff65caa05195d81a97', '0ba56b09d0fac85d23bce3ffa271e4', '{"expiryMonth":"21","expiryYear":"15","pan":"21584364","cvv":"123","type":"CC"}', '9d45c2a2b522ff5bea40797d728f098d', 6, 1),
('a050e8b2ba8a5d9ece0f969ae205f5', '0ba56b09d0fac85d23bce3ffa271e4', '{"accountNumber":"Accoun57286","routingNumber":"Routen7379","type":"DD"}', '342da15d7e5d4d3d7b567b1f58058be4', 12, 0),
('a3097b09d007eb78d883acbad54f96', '0ba56b09d0fac85d23bce3ffa271e4', '{"type":"CC","pan":"asdfdssd","expiryMonth":"sd","expiryYear":"sd","cvv":"sadf"}', 'f80675aee4c23674b045713d66df7fb5', 2, 1),
('a821978da61f17bf12a9c2da2264e5', '0ba56b09d0fac85d23bce3ffa271e4', '{"expiryMonth":"23","expiryYear":"23","pan":"qeqwr","cvv":"123","type":"CC"}', '4941c7acb6b2066b182884f5d3602527', 5, 0),
('ae8dca4a3bf9495b287e15afd70125', '0ba56b09d0fac85d23bce3ffa271e4', '{"accountNumber":"Hahbsb","routingNumber":"Hhshhhs","type":"DD"}', 'd3bc14d388381d7ecc148aa23785d9c7', 10, 0),
('b2fc4d916236e6b4466daf57c5fdb9', '0ba56b09d0fac85d23bce3ffa271e4', '{"accountNumber":"Ybsndbdj","routingNumber":"Shcndj","type":"DD"}', '94fb9986e894d90de6ffa2555a106ccd', 13, 1),
('cead53e074f5137ddaa054387637d1', '0ba56b09d0fac85d23bce3ffa271e4', '{"type":"CC","pan":"0123456789","expiryMonth":"12","expiryYear":"20","cvv":"1223"}', 'a2d5a5eae188662316f8742f32d92f2c', 1, 1),
('d231c1d98c4d5c789c20db9479cd43', '0ba56b09d0fac85d23bce3ffa271e4', '{"pan":"548484","expiryMonth":"21","type":"CC","expiryYear":"54","cvv":"5154"}', 'b4bc9e4b7b591a555acb17a6be735c4c', 0, 1),
('d6d37f1eb3800285db709e0cc03e03', '0ba56b09d0fac85d23bce3ffa271e4', '{"type":"PAYPAL"}', '4c3a62b6ddfa717c48362ec5c43e168b', 9, 0),
('fd19d60b7abe1eac87d1df30c5f7d7', '5d1e7e08abfc13807d1a1d42c22ad8', '{"iban":"RO23441183838","type":"SEPA"}', '8999121508907a4271458abb059be535', 3, 1);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `PITABLE`
--
ALTER TABLE `PITABLE`
 ADD UNIQUE KEY `piToken` (`piToken`), ADD UNIQUE KEY `piHash` (`identifier`), ADD KEY `userToken` (`userToken`);
