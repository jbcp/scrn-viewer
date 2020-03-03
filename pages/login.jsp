<%@ page language="java" 
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
	<meta name="description" content="Responsive Bootstrap 4 Admin Template">
	<meta name="author" content="Bootlab">

	<title>SCRN</title>

	<link href="../css/app.css" rel="stylesheet">


</head>
<body>
 	<main class="main h-100 w-100 bg-white">
		<div class="container h-100">
			<div class="row h-100">
				<div class="col-sm-10 col-md-8 col-lg-6 mx-auto d-table h-100">
					<div class="d-table-cell align-middle">
						<div class="card" style="border-color:transparent" >
							<div class="card-body">
								<label style="font-size: 25px; color: rgb(52, 60, 67); margin-left: 24px; font-weight: bold"><i class="align-middle" style="margin-right : 5px; color:rgb(12, 194, 170)" data-feather="navigation"></i>SCRN</label>
								<br>
								<label style="font-size: 15px; color: rgb(52, 60, 67); margin-left: 24px; font-weight: bold">Smart Clinical Research Navigator</label>

								<div class="m-sm-4">
								<%if(session.getAttribute("user_id") == null) { %>
									<form action="login_back.jsp" method="post">
										<div class="form-group">
											<label>Email</label>
											<input name = "id" type="id" class="form-control form-control-lg" id="inputEmail"  placeholder="Enter your id" />
										</div>
										<div class="form-group">
											<label>Password</label>
											<input name="password" class="form-control form-control-lg" id="inputPassword" type="password" placeholder="Enter your password" />
											<small>
										</small>
										</div>
										<div class="text-center mt-3">
											<button class="btn btn-lg btn-primary">Sign in</button>
										</div>
									</form>
								<%}
								else  response.sendRedirect("logout.jsp");%>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</main>

	<script src="../js/app.js"></script>
    
</body>
</html>


