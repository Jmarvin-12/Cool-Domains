// Funcion que se encarga de desplegar el contrato en la blockchain
const main = async () => {
    const owner = await hre.ethers.getSigners();
    // Se obtiene la referencia del contrato a desplegar mediante ethers y la funcion getContractFactory
    const domainContractFactory = await hre.ethers.getContractFactory('Domains')
    // Una vez obtenida la referencia, desplegamod el contrato 
    const domainContract = await domainContractFactory.deploy("MB")
    await domainContract.deployed()
    console.log("contrato desplegado con direccion: ", domainContract.address)
    
    console.log("Contrato desplegado por: ", owner.address);

    let domini = await domainContract.getDominios();
    console.log("Dominios minteados ", domini );

    let txn = await domainContract.register("socecondir", {value: hre.ethers.utils.parseEther('0.1')});
    await txn.wait();

    let dominiosAg = await domainContract.getDominios();
    console.log("Dominios minteados (agregado) ", dominiosAg );

    const domainOwner = await domainContract.getAddress("socecondir");
    console.log("Propietario del dominio: ", domainOwner);

    const balance = await hre.ethers.provider.getBalance(domainContract.address);    
    console.log("Balance del contrato: ", hre.ethers.utils.formatEther(balance));
    
    // txn = await domainContract.connect(randomPerson).setRecord("doom", "Ahora mio");
    // await txn.wait();

    // txn = await domainContract.setRecord("doom", "jaime@gmail.com");
    // await txn.wait();

    // // Obtenemos informacion del dominio registrada en un dominio.
    // let record = await domainContract.getRecord("doom");
    // console.log("Informacion registrada en el dominio doom fue: ", record);

};

// Funcion auxiliar para ejecutar la funcion main. 
// Con try-catch evalua si la ejecucion de main() se da sin error, de haber error lo mostrara en la consola
const runMain = async () => {
    try{
        await main();
        process.exit(0);
    }catch (error) {
        console.log(error);
        process.exit(1);
    }
};

//llamada de ejecucion de funcion runMain
runMain();