FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["NovinskiPortal.API/NovinskiPortal.API.csproj", "NovinskiPortal.API/"]
COPY ["NovinskiPortal.Common/NovinskiPortal.Common.csproj", "NovinskiPortal.Common/"]
COPY ["NovinskiPortal.Services/NovinskiPortal.Services.csproj", "NovinskiPortal.Services/"]
COPY ["NovinskiPortal.Model/NovinskiPortal.Model.csproj", "NovinskiPortal.Model/"]
RUN dotnet restore "./NovinskiPortal.API/NovinskiPortal.API.csproj"
COPY . .
WORKDIR "/src/NovinskiPortal.API"
RUN dotnet build "./NovinskiPortal.API.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./NovinskiPortal.API.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "NovinskiPortal.API.dll"]
