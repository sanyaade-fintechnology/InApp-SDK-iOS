-- phpMyAdmin SQL Dump
-- version 4.2.10
-- http://www.phpmyadmin.net
--
-- Host: localhost:3306
-- Erstellungszeit: 14. Nov 2014 um 09:42
-- Server Version: 5.5.38
-- PHP-Version: 5.6.2

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

--
-- Datenbank: `inAppPayment`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `PITABLE`
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
-- Daten für Tabelle `PITABLE`
--

INSERT INTO `PITABLE` (`piToken`, `userToken`, `piDetails`, `identifier`, `piIndex`, `piEnabled`) VALUES
('09111b5d354469321747ddcf53179d', '0ba56b09d0fac85d23bce3ffa271e4', '{"authToken":"q4234wer","type":"PAYPAL"}', '03bf1fc08c908e1f1701475a46b198c7', 6, 1),
('24650827867b89d55837bf75f3c3f0', '0ba56b09d0fac85d23bce3ffa271e4', '{"ccv":"sadf","expiryMonth":"12","expiryYear":"12","pan":"123123","type":"CC"}', 'f1533864395ca8f60eba795ed32b1e9f', 3, 1),
('3a2b08223ca7e501f80c8c97ec00cf', '37c339b0435f4f22639b713e15a1b9', '{"authToken":"paypal_auth_token","type":"PAYPAL"}', '503d4aa91c1bb07316192070310786a7', 0, 1),
('434558b4a6a4819876047faf9ff5ec', '37c339b0435f4f22639b713e15a1b9', '{"cvv":"123","expiryMonth":"02","expiryYear":"02","pan":"123456789123456","type":"CC"}', '661912a8b60e88f3bb6915cddb3e7296', 2, 1),
('47ad404275ae06ed1fbd85f5ca5b3f', '0ba56b09d0fac85d23bce3ffa271e4', '{"authToken":"dasfasdgasdg","type":"PAYPAL"}', '740491d1e346efc979c1f4a67c8859b6', 7, 1),
('48eb167fd1d452ebe3b6a77d0673e5', '0ba56b09d0fac85d23bce3ffa271e4', '{"ccv":"1232","expiryMonth":"12","expiryYear":"12","pan":"abcdef","type":"CC"}', '1ecbc65511394d82eb381e3d5817adf0', 4, 1),
('534d88cf108a22eb28d95a54e1a2cb', '37c339b0435f4f22639b713e15a1b9', '{"cvv":"123","expiryMonth":"01","expiryYear":"01","pan":"2184343561243465","type":"CC"}', 'd43505995962b523938db82b6259f16f', 5, 1),
('5e7e964124686ec1caa322688100aa', '37c339b0435f4f22639b713e15a1b9', '{"iban":"xfffrtt","type":"SEPA"}', '0b88ff5435f5847c03839589cb66b735', 1, 1),
('6b7a24f8e77d45273bbe365b389d65', '0ffadd28dd395fe9ab7601e5a848e0', '{"ccv":"2424","expiryMonth":"12","expiryYear":"24","pan":"23412412","type":"CC"}', '496793865fb535408830c72f38c888d0', 0, 1),
('7b6a7384a6439b3fb8eff9c8806030', '0ba56b09d0fac85d23bce3ffa271e4', '{"authToken":"1232343241235","type":"PAYPAL"}', '8423e9e8c426a82b4fbb201b5db34a9c', 8, 1),
('843eef363b543dd658086b725cc444', '0ba56b09d0fac85d23bce3ffa271e4', '{"type":"PAYPAL"}', '4c3a62b6ddfa717c48362ec5c43e168b', 5, 1),
('a3097b09d007eb78d883acbad54f96', '0ba56b09d0fac85d23bce3ffa271e4', '{"type":"CC","pan":"asdfdssd","expiryMonth":"sd","expiryYear":"sd","ccv":"sadf"}', 'f80675aee4c23674b045713d66df7fb5', 2, 1),
('c2934d745f9f19cb1b695f67057a56', '0ba56b09d0fac85d23bce3ffa271e4', '{"expiryMonth":"11","expiryYear":"13","pan":"12312","type":"CC"}', '061cbbe4057dd35716ac5c77da7f831e', 9, 1),
('cead53e074f5137ddaa054387637d1', '0ba56b09d0fac85d23bce3ffa271e4', '{"type":"CC","pan":"0123456789","expiryMonth":"12","expiryYear":"20","ccv":"1223"}', 'a2d5a5eae188662316f8742f32d92f2c', 1, 1),
('cfc2111b4070851d85b505b55dd87c', '0ffadd28dd395fe9ab7601e5a848e0', '{"ccv":"1244","expiryMonth":"12","expiryYear":"12","pan":"1234567","type":"CC"}', 'fb716cead672f9cbaa30349c14221f26', 1, 1),
('d231c1d98c4d5c789c20db9479cd43', '0ba56b09d0fac85d23bce3ffa271e4', '{"pan":"548484","expiryMonth":"21","type":"CC","expiryYear":"54","ccv":"5154"}', 'b4bc9e4b7b591a555acb17a6be735c4c', 0, 1),
('d3ee6fb4bb56c159fdc5872a5aaa51', '37c339b0435f4f22639b713e15a1b9', '{"iban":"123464828829","type":"SEPA"}', '4b86ab22e545f0d75829cea98502be66', 3, 1),
('e7055830d9d2d552c4f3bf92817377', '37c339b0435f4f22639b713e15a1b9', '{"accountNo":"526272737","routingNo":"262627","type":"DD"}', '65c8d67e36ef5cbcd3ed1a56b7a31351', 4, 1),
('f5f8db6b09621406c243e5e45592b9', '0ffadd28dd395fe9ab7601e5a848e0', '{"type":"PAYPAL"}', '7c944b33b15d591e1641f2ae3e34aaac', 2, 1);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `SERVICEURLS`
--

CREATE TABLE `SERVICEURLS` (
`id` int(11) NOT NULL,
  `apiKey` varchar(255) NOT NULL,
  `apiVersion` varchar(8) NOT NULL,
  `bundleID` varchar(255) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

--
-- Daten für Tabelle `SERVICEURLS`
--

INSERT INTO `SERVICEURLS` (`id`, `apiKey`, `apiVersion`, `bundleID`) VALUES
(1, '4840bbc6429dacd56bfa98390ddf43', '1.0', 'com.payleven.payment.PaylevenInAppSDKExample'),
(2, 'nAj6Rensh2Ew3Oc4Ic2gig1F', '1.0', 'com.test.payment'),
(3, 'nAj6Rensh2Ew3Oc4Ic2gig1F', '1.0', 'de.payleven.inappdemo'),
(4, 'cad1e1e506ded49e6c579603e155f7', '1.0', 'com.test.paymenfsdtsdsdsd'),
(5, '8354a42049aeae538f741595cb3fca', '1.0', 'com.test.paymenfsdcvcvsd');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `USECASETABLE`
--

CREATE TABLE `USECASETABLE` (
`id` int(11) NOT NULL,
  `userToken` varchar(255) NOT NULL,
  `piToken` varchar(255) NOT NULL,
  `useCase` varchar(16) NOT NULL DEFAULT 'PRIVATE',
  `sortIndex` int(11) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8;

--
-- Daten für Tabelle `USECASETABLE`
--

INSERT INTO `USECASETABLE` (`id`, `userToken`, `piToken`, `useCase`, `sortIndex`) VALUES
(15, '0ba56b09d0fac85d23bce3ffa271e4', 'a3097b09d007eb78d883acbad54f96', 'PRIVATE', 2),
(16, '0ba56b09d0fac85d23bce3ffa271e4', '24650827867b89d55837bf75f3c3f0', 'PRIVATE', 0),
(19, '0ffadd28dd395fe9ab7601e5a848e0', '6b7a24f8e77d45273bbe365b389d65', 'PRIVATE', 0),
(20, '0ffadd28dd395fe9ab7601e5a848e0', 'cfc2111b4070851d85b505b55dd87c', 'BUSINESS', 0),
(21, '0ffadd28dd395fe9ab7601e5a848e0', 'f5f8db6b09621406c243e5e45592b9', 'PRIVATE', 1),
(24, '37c339b0435f4f22639b713e15a1b9', '3a2b08223ca7e501f80c8c97ec00cf', 'PRIVATE', 0),
(25, '37c339b0435f4f22639b713e15a1b9', '5e7e964124686ec1caa322688100aa', 'PRIVATE', 1),
(27, '0ba56b09d0fac85d23bce3ffa271e4', 'c2934d745f9f19cb1b695f67057a56', 'PRIVATE', 1),
(28, '37c339b0435f4f22639b713e15a1b9', '434558b4a6a4819876047faf9ff5ec', 'BUSINESS', 0),
(29, '37c339b0435f4f22639b713e15a1b9', 'd3ee6fb4bb56c159fdc5872a5aaa51', 'PRIVATE', 2),
(30, '37c339b0435f4f22639b713e15a1b9', 'e7055830d9d2d552c4f3bf92817377', 'PRIVATE', 3),
(31, '37c339b0435f4f22639b713e15a1b9', '534d88cf108a22eb28d95a54e1a2cb', 'PRIVATE', 4),
(32, '37c339b0435f4f22639b713e15a1b9', '534d88cf108a22eb28d95a54e1a2cb', 'BUSINESS', 1);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `USERS`
--

CREATE TABLE `USERS` (
`identifier` bigint(255) NOT NULL,
  `userToken` varchar(48) NOT NULL,
  `email` varchar(255) NOT NULL,
  `apiKey` varchar(255) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8;

--
-- Daten für Tabelle `USERS`
--

INSERT INTO `USERS` (`identifier`, `userToken`, `email`, `apiKey`) VALUES
(26, '0ba56b09d0fac85d23bce3ffa271e4', 'test@test.de', '4840bbc6429dacd56bfa98390ddf43'),
(27, '37c339b0435f4f22639b713e15a1b9', 'test@test.com', 'nAj6Rensh2Ew3Oc4Ic2gig1F'),
(28, '0ffadd28dd395fe9ab7601e5a848e0', 'mike@dummy.de0', '4840bbc6429dacd56bfa98390ddf43');

--
-- Indizes der exportierten Tabellen
--

--
-- Indizes für die Tabelle `PITABLE`
--
ALTER TABLE `PITABLE`
 ADD UNIQUE KEY `piToken` (`piToken`), ADD UNIQUE KEY `piHash` (`identifier`), ADD KEY `userToken` (`userToken`);

--
-- Indizes für die Tabelle `SERVICEURLS`
--
ALTER TABLE `SERVICEURLS`
 ADD PRIMARY KEY (`id`);

--
-- Indizes für die Tabelle `USECASETABLE`
--
ALTER TABLE `USECASETABLE`
 ADD PRIMARY KEY (`id`);

--
-- Indizes für die Tabelle `USERS`
--
ALTER TABLE `USERS`
 ADD PRIMARY KEY (`identifier`);

--
-- AUTO_INCREMENT für exportierte Tabellen
--

--
-- AUTO_INCREMENT für Tabelle `SERVICEURLS`
--
ALTER TABLE `SERVICEURLS`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT für Tabelle `USECASETABLE`
--
ALTER TABLE `USECASETABLE`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=33;
--
-- AUTO_INCREMENT für Tabelle `USERS`
--
ALTER TABLE `USERS`
MODIFY `identifier` bigint(255) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=29;