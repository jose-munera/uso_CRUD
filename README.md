# NOTÓMETRO 🌡️

## Integrantes
José Isaías Munera Mora

## Descripción del módulo

NOTA: Para acceder al módulo, selecciona el ícono del libro abierto, en la esquina superior derecha de la pantalla, al lado del ícono de settings.

    La aplicación Notómetro se le ha agregado como plus adicional de funcionamiento las carpetas "models", "services" y "validators" para cumplir con los parámetros básicos de un CRUD simulado. En este caso, se trata de agregar materias y listarlas, sus datos son: Nombre, Semestre y Créditos.
    La pantalla principal de "Mis Materias" permite ver cada una de las mismas, y por supuesto, cada una de ellas muestra el ID generado por la librería UUID.

    Se guarda la materia con los datos ingresados, los cuales tienen parámetros establecidos (validación de formulario) de manera que la información ingresada sea correcta y deseada, de lo contrario surgirán los respectivos mensajes de alerta.

    Se encuentra las opciones de editar y eliminar. La opción eliminar genera un mensaje de confirmación antes de proceder con la depuración. También, esta la opción de buscar materias por nombre y semestre.

    Cada vez que se edita o se elimina una materia, genera la simulación del tiempo de red, gracias a Future.delayed(const Duration(milliseconds: 500)).

   ## Evidencias
   ![Buscar] (screenshots/buscar.jpeg)
   ![Editar] (screenshots/editar.jpeg)
   ![Eliminar] (screenshots/eliminar.jpeg)
   ![Listar] (screenshots/listar.jpeg)
   ![Nueva_Materia] (screenshots/nueva_materia.jpeg)



