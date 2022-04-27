// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import { StringUtils } from "./libraries/StringUtils.sol";
import {Base64} from "./libraries/Base64.sol";
import "hardhat/console.sol";

contract Domains is ERC721URIStorage {
    //Funcion provista por la libreria de openzeppelin para llevar un registro de los ids de los tokens
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds; 

    string public ltd;
    address payable public owner;

    //El NFT que se almancenara sera un svg
    string svgPartOne = '<svg xmlns="http://www.w3.org/2000/svg" width="270" height="270" fill="none"><path fill="url(#B)" d="M0 0h270v270H0z"/><defs><filter id="A" color-interpolation-filters="sRGB" filterUnits="userSpaceOnUse" height="270" width="270"><feDropShadow dx="0" dy="1" stdDeviation="2" flood-opacity=".225" width="200%" height="200%"/></filter></defs><path d="M72.863 42.949c-.668-.387-1.426-.59-2.197-.59s-1.529.204-2.197.59l-10.081 6.032-6.85 3.934-10.081 6.032c-.668.387-1.426.59-2.197.59s-1.529-.204-2.197-.59l-8.013-4.721a4.52 4.52 0 0 1-1.589-1.616c-.384-.665-.594-1.418-.608-2.187v-9.31c-.013-.775.185-1.538.572-2.208a4.25 4.25 0 0 1 1.625-1.595l7.884-4.59c.668-.387 1.426-.59 2.197-.59s1.529.204 2.197.59l7.884 4.59a4.52 4.52 0 0 1 1.589 1.616c.384.665.594 1.418.608 2.187v6.032l6.85-4.065v-6.032c.013-.775-.185-1.538-.572-2.208a4.25 4.25 0 0 0-1.625-1.595L41.456 24.59c-.668-.387-1.426-.59-2.197-.59s-1.529.204-2.197.59l-14.864 8.655a4.25 4.25 0 0 0-1.625 1.595c-.387.67-.585 1.434-.572 2.208v17.441c-.013.775.185 1.538.572 2.208a4.25 4.25 0 0 0 1.625 1.595l14.864 8.655c.668.387 1.426.59 2.197.59s1.529-.204 2.197-.59l10.081-5.901 6.85-4.065 10.081-5.901c.668-.387 1.426-.59 2.197-.59s1.529.204 2.197.59l7.884 4.59a4.52 4.52 0 0 1 1.589 1.616c.384.665.594 1.418.608 2.187v9.311c.013.775-.185 1.538-.572 2.208a4.25 4.25 0 0 1-1.625 1.595l-7.884 4.721c-.668.387-1.426.59-2.197.59s-1.529-.204-2.197-.59l-7.884-4.59a4.52 4.52 0 0 1-1.589-1.616c-.385-.665-.594-1.418-.608-2.187v-6.032l-6.85 4.065v6.032c-.013.775.185 1.538.572 2.208a4.25 4.25 0 0 0 1.625 1.595l14.864 8.655c.668.387 1.426.59 2.197.59s1.529-.204 2.197-.59l14.864-8.655c.657-.394 1.204-.95 1.589-1.616s.594-1.418.609-2.187V55.538c.013-.775-.185-1.538-.572-2.208a4.25 4.25 0 0 0-1.625-1.595l-14.993-8.786z" fill="#fff"/><defs><linearGradient id="B" x1="0" y1="0" x2="270" y2="270" gradientUnits="userSpaceOnUse"><stop stop-color="#cb5eee"/><stop offset="1" stop-color="#0cd7e4" stop-opacity=".99"/></linearGradient></defs><text x="32.5" y="231" font-size="27" fill="#fff" filter="url(#A)" font-family="Plus Jakarta Sans,DejaVu Sans,Noto Color Emoji,Apple Color Emoji,sans-serif" font-weight="bold">';
    string svgPartTwo = '</text></svg>';

    // mapping para guardar los nombres de dominio
    mapping (string => address) public domains;
    mapping (uint => string ) public nombresDominio;

    string[] public dominios;

    // Mapping que guardara valores
    mapping (string => string) public records;

    constructor(string memory _ltd) payable ERC721("MacroBlock", "MACRO") {
        owner = payable(msg.sender);
        ltd = _ltd;
        console.log("%s name service deployed", _ltd);
    }

    //   Errors
    error Unauthorized();
    error AlreadyRegistered();
    error InvalidName(string name);

    function price(string calldata name) public pure returns(uint) {
        uint len = StringUtils.strlen(name);
        require(len > 0, "valor nulo");
        if(len ==3) {
            return 5 * 10**17;
        }else if (len == 4){
            return 3 * 10**17;
        }else {
            return 1 * 10**17;
        }
    }

    //Funcion para registrar el nombre, ligarlo a la direccion y guardarlo en el mapping
    function register(string calldata name) public payable{
        //require(domains[name] == address(0), "Este dominio ya fue registrado por otra direccion");
        if(domains[name] != address(0)) revert AlreadyRegistered();

        if(!valid(name)) revert InvalidName(name); //Errores custom revierten cambios si se producen

        uint _price = price(name);
        require(msg.value >= _price, "No hay suficiente matic en su cartera");

        // Combinacion del nombre con el dominio
        string memory _name = string(abi.encodePacked(name, ".", ltd));
        //Creacion del SVG con el nombre de dominio para convertirlo a NFT
        string memory finalSvg = string(abi.encodePacked(svgPartOne, _name, svgPartTwo));

        dominios.push(_name);

        uint256 newRecordId = _tokenIds.current();
        uint256 length = StringUtils.strlen(name);
        string memory strLen = Strings.toString(length);

        console.log("Se ha registrado %s.%s en el contrato con TokenID %d", name, ltd, newRecordId);

        //Creacion la metadata JSON utilizada para el NFT, esto se logra con strings y codificando como base64
        string memory json = Base64.encode(
            bytes(
                string(
                abi.encodePacked(
                    '{"name": "',
                    _name,
                    '", "description": "Un dominio en el MacroBlockchain name service", "image": "data:image/svg+xml;base64,',
                    Base64.encode(bytes(finalSvg)),
                    '","length":"',
                    strLen,
                    '"}'
                )
                )
            )
            );

        string memory finalTokenUri = string( abi.encodePacked("data:application/json;base64,", json));

        console.log("\n--------------------------------------------------------");
	    console.log("Final tokenURI", finalTokenUri);
	    console.log("--------------------------------------------------------\n");

        _safeMint(msg.sender, newRecordId);
        _setTokenURI(newRecordId, finalTokenUri);

        domains[name] = msg.sender;
        console.log("%s ha registrado un dominio: ", msg.sender);

        nombresDominio[newRecordId] = name;
        _tokenIds.increment();
        
    }

    function getDominios() public view returns(string[] memory){
        return dominios;
    }

    //Funcion para obtener la direccion del nombre de dominio
    function getAddress(string calldata name) public view returns(address) {
        return domains[name];
    }

    function setRecord(string calldata name, string calldata record) public {
        //Checa que el que llama la funcion sea el propietario
      // require(domains[name] == msg.sender, "Usted no esta autorizado a interactuar con este dominio");
        if(domains[name] != msg.sender) revert Unauthorized();
        records[name] = record;
    }

    function getRecord(string calldata name) public view returns(string memory) {
        return records[name];
    }

    //Modifier que servira para que las funciones especificada con el solo sean ejecutadas por el owner del contrato
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns(bool) {
        return msg.sender == owner;
    }

    function withdraw() public onlyOwner {
        //Obtenemos el balance del contrato y se almacena en la variable amount
        uint amount = address(this).balance;
        // Lo que hace es que msg.sender.call le pasa el monto del balance del contrato en amount.
        // De esa forma se retiran los fondos del contrato y pasan a la direccion del que llama la funcion
        //es decir, el owner del contrato. Al final si la operacion es exitosa success se setea a true
        (bool success, ) = msg.sender.call{value: amount}("");
        //Si success no es True da error y revierte los cambios
        require(success, "Fijese que el retiro de fondos fallo");
    }

    function getAllNames() public view returns (string[] memory) {
        console.log("Obtendremos todos los nombres de dominio del contrato");
        
        string[] memory allNames = new string[](_tokenIds.current());
        
        for(uint i = 0; i< _tokenIds.current(); i++){
            allNames[i] = nombresDominio[i];
            console.log("El nombre de dominio para el token %s es %s", i, allNames[i]);
        }

        return allNames;
    }

    function valid(string calldata _name) public pure returns(bool){
        return StringUtils.strlen(_name) >= 3 && StringUtils.strlen(_name) <=10;
    }

}