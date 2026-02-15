#! /bin/bash


name=$1
touch ./src/exceptions/"$name".java

echo "/**
       * @author Sofia Nunes (68651) sr.nunes@campus.fct.unl.pt
       * @author Manuel Oliveira (68547) mpi.oliveira@campus.fct.unl.pt
       */
package exceptions;
public class $name extends RuntimeException{
    static final long serialVersionUID = 0L;
}" >> ./src/exceptions/"$name".java
